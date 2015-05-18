#!/bin/bash -e

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"	
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

MACHINE_TYPE=`uname -m`
if [ ${MACHINE_TYPE} == 'x86_64' ]; then
  # 64-bit
  echo -e "$COL_BLUE * 64-bit detected $COL_RESET"
  cfbinfile="ColdFusion_10_WWEJ_linux64.bin"
  jretarfile="jre-7u15-linux-x64.tar.gz"
else
  # 32-bit
  echo -e "$COL_BLUE * 32-bit detected $COL_RESET"
  cfbinfile="ColdFusion_10_WWEJ_linux32.bin"
  jretarfile="jre-7u15-linux-i586.tar.gz"
fi
hotfixfile="hotfix_016.jar"

echo -e "$COL_CYAN * running install.sh $COL_RESET"

sudo apt-get update -qq
sudo apt-get install "git-core" "curl" "nmap" "discus" "htop" "unzip" "xmlstarlet" "dos2unix" -y -q

if id -u coldfusion >/dev/null 2>&1; then
	echo -e "$COL_GREEN * users exist $COL_RESET"
else
	echo -e "$COL_YELLOW * users does not exist $COL_RESET"
	sudo useradd -r -s /bin/false coldfusion
	sudo usermod -a -G www-data coldfusion
	sudo usermod -a -G www-data vagrant
fi

# Postfix + Dovecot + SquirrelMail
if [ -d /etc/postfix/ ]; then
	echo -e "$COL_GREEN * postfix exists $COL_RESET"
else
	echo -e "$COL_YELLOW * postfix does not exist $COL_RESET"
	sudo printf "show_html_default=1\n" | sudo tee -a /var/lib/squirrelmail/data/vagrant.pref
fi

sudo postconf -e "luser_relay = vagrant@localhost"
sudo postconf -e "local_recipient_maps ="
sudo postconf -e "strict_mailbox_ownership = no"
sudo postconf -e "mydestination = pcre:/etc/postfix/mydestinations"
sudo postconf -e "mail_spool_directory = /vagrant/mail"
sudo postconf -e "default_transport = error:outside mail is not deliverable"
sudo printf "/.*/         ACCEPT\n" | sudo tee /etc/postfix/mydestinations

rm ~/Maildir/* -rf

sudo cp /etc/squirrelmail/apache.conf /etc/apache2/sites-available/squirrelmail -f
sudo ln -s /etc/apache2/sites-available/squirrelmail /etc/apache2/sites-enabled/squirrelmail -f

# Fonts
if [ -d /usr/share/fonts/truetype/msttcorefonts/ ]; then
	echo -e "$COL_GREEN * fonts exist $COL_RESET"
else
	echo -e "$COL_YELLOW * fonts does not exist $COL_RESET"
	sudo sh -c "echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections"
	sudo apt-get install fontconfig ttf-mscorefonts-installer -y -q
	sudo fc-cache -f -v
fi

# Coldfusion
if [ -d /opt/coldfusion10 ]; then
	echo -e "$COL_GREEN * coldfusion10 exists $COL_RESET"
else
	echo -e "$COL_YELLOW * coldfusion10 does not exist $COL_RESET"


	if [[ -f /vagrant/files/downloads/$cfbinfile ]]; then
		cp /vagrant/files/downloads/$cfbinfile ./$cfbinfile -f
	else
		file-not-found
	fi
	chmod +x ./$cfbinfile
	sudo ./$cfbinfile -f /vagrant/installer.profile 
	sudo sed -i 's/<!--<adapter>coldfusion.flash.adapter.CFWSAdapter<\/adapter>-->/<adapter>coldfusion.flash.adapter.CFWSAdapter<\/adapter>/g' /opt/coldfusion10/cfusion/wwwroot/WEB-INF/gateway-config.xml

	xmlstarlet ed --subnode "//session-config" --type elem -n cookie-config -v "" /opt/coldfusion10/cfusion/wwwroot/WEB-INF/web.xml > /tmp/web.xml
	sudo mv /tmp/web.xml /opt/coldfusion10/cfusion/wwwroot/WEB-INF/web.xml

	xmlstarlet ed --subnode "//session-config/cookie-config" --type elem -n http-only -v "true" /opt/coldfusion10/cfusion/wwwroot/WEB-INF/web.xml > /tmp/web.xml
	sudo mv /tmp/web.xml /opt/coldfusion10/cfusion/wwwroot/WEB-INF/web.xml

	xmlstarlet ed --subnode "//session-config/cookie-config" --type elem -n secure -v "false" /opt/coldfusion10/cfusion/wwwroot/WEB-INF/web.xml > /tmp/web.xml
	sudo mv /tmp/web.xml /opt/coldfusion10/cfusion/wwwroot/WEB-INF/web.xml

	xmlstarlet ed --update "//serialize-array-to-arraycollection" --value "true" /opt/coldfusion10/cfusion/wwwroot/WEB-INF/flex/services-config.xml > /tmp/services-config.xml
	sudo mv /tmp/services-config.xml /opt/coldfusion10/cfusion/wwwroot/WEB-INF/flex/services-config.xml

	sudo /opt/coldfusion10/cfusion/runtime/bin/wsconfig -ws Apache -dir /etc/apache2 -v -script /usr/sbin/apache2ctl -bin /usr/sbin/apache2

	if [[ -f /vagrant/files/downloads/$jretarfile ]]; then
		cp /vagrant/files/downloads/$jretarfile ./jre.tar.gz -f
	else
		file-not-found
	fi
	sudo tar -xzvf jre.tar.gz -C /opt/


fi

# updates
wget -q http://download.macromedia.com/pub/coldfusion/10/cf10_mdt_updt.jar -O /tmp/cf10_mdt_updt.jar
sudo java -jar /tmp/cf10_mdt_updt.jar -f /vagrant/installer.profile

wget -q http://download.adobe.com/pub/adobe/coldfusion/$hotfixfile -O /tmp/$hotfixfile
sudo java -jar /tmp/$hotfixfile -f /vagrant/installer.profile


sudo cp /vagrant/files/cfusion/jvm.config /opt/coldfusion10/cfusion/bin/jvm.config 
sudo dos2unix /opt/coldfusion10/cfusion/bin/jvm.config
sudo cp /vagrant/files/cfusion/wwwroot/* /opt/coldfusion10/cfusion/wwwroot/ -R
sudo rm /opt/coldfusion10/cfusion/logs/*.log -f

sudo sed -i 's/org.apache.log4j.FileAppender/org.apache.log4j.RollingFileAppender/g' /opt/coldfusion10/cfusion/lib/log4j.properties
sudo sed -i 's/#log4j.appender.HIBERNATECONSOLE.MaxFileSize=500KB/log4j.appender.HIBERNATECONSOLE.MaxFileSize=1000KB/g' /opt/coldfusion10/cfusion/lib/log4j.properties


sudo printf "ServerName localhost\n<VirtualHost *:80>\nServerAdmin men@rhinofly.nl\nDocumentRoot /vagrant/\nServerName vagrant.local\n</VirtualHost>\n" | sudo tee /etc/apache2/sites-enabled/vagrant
sudo printf "NameVirtualHost *:80\nNameVirtualHost *:443\nListen 80\nListen 443\n" | sudo tee /etc/apache2/ports.conf

sudo cp /vagrant/files/apache2/sites-enabled/001-basic.conf /etc/apache2/sites-enabled/
sudo cp /vagrant/files/apache2/static_files.conf /etc/apache2/conf.d/

if [ -d /etc/apache2/ssl/ ]; then
	echo -e "$COL_GREEN * apache/ssl exists $COL_RESET"
else
	echo -e "$COL_YELLOW * apache/ssl does not exists $COL_RESET"
	sudo mkdir /etc/apache2/ssl/
fi

sudo a2enmod ssl
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod proxy_http
sudo a2enmod proxy
sudo a2enmod expires
sudo a2enmod deflate
sudo a2enmod filter

if [[ ! -f /etc/apache2/ssl/localhost.pem ]]; then 
	sudo openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=NL/ST=None/L=Utrecht/O=Rhinofly/CN=localhost" -keyout /etc/apache2/ssl/localhost.key -out /etc/apache2/ssl/localhost.crt
	sudo cat /etc/apache2/ssl/localhost.crt | sudo tee /etc/apache2/ssl/localhost.pem
	sudo cat /etc/apache2/ssl/localhost.key | sudo tee -a /etc/apache2/ssl/localhost.pem
fi

sudo rm /etc/apache2/mods-enabled/dir.conf -f

sudo chown coldfusion:coldfusion /opt/coldfusion10/ -R

if sudo lsof -P | grep :8500; then
  echo -e "$COL_BLUE * ColdFusion restart... $COL_RESET"
  sudo /opt/coldfusion10/cfusion/bin/coldfusion restart
else
  echo -e "$COL_BLUE * ColdFusion start... $COL_RESET"
  sudo /opt/coldfusion10/cfusion/bin/coldfusion start
fi

sudo service apache2 restart

sudo cp /vagrant/files/hosts.txt /etc/hosts -f

echo -e "$COL_MAGENTA * Running ColdFusion scripts... $COL_RESET"

curl "http://localhost:8500/install.cfm" -s -S

lsb_release -rdc

echo -e "$COL_CYAN * DONE! $COL_RESET"
