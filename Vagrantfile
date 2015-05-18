# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.5.3"

if ! File.exists?('./files/downloads/ColdFusion_10_WWEJ_linux64.bin')
  puts 'ColdFusion installer could not be found!'
  puts "Please run:\n  wget https://www.dropbox.com/s/cgmycpeeu7pjelr/ColdFusion_10_WWEJ_linux64.bin?dl=1 -O ./files/downloads/ColdFusion_10_WWEJ_linux64.bin"
  exit 1
end

if ! File.exists?('./files/downloads/ColdFusion_10_WWEJ_linux64.bin')
  puts 'Java 7 installer could not be found!'
  puts "Please run:\n  wget https://www.dropbox.com/s/96w4ssf89uzx570/jre-7u15-linux-x64.tar.gz?dl=1 -O ./files/downloads/jre-7u15-linux-x64.tar.gz"
  exit 1
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  # for doing git clones
  config.ssh.forward_agent = true

  config.vm.box = "hashicorp/precise64"
  config.vm.box_url = "https://vagrantcloud.com/hashicorp/precise64"

  config.vm.network :private_network, ip: "10.0.0.10"
  config.nfs.map_gid = Process.gid
 
  config.vm.network "forwarded_port", guest: 8500, host: 8520 # CF admin

  config.vm.network "forwarded_port", guest: 80, host: 8880 # http
  config.vm.network "forwarded_port", guest: 443, host: 8443 # https
  config.vm.network "forwarded_port", guest: 8983, host: 8983 # solr
  config.vm.network "forwarded_port", guest: 9000, host: 9020 # Play
  config.vm.network "forwarded_port", guest: 9200, host: 9220 # ElasticSearch
  config.vm.network "forwarded_port", guest: 25, host: 2525 # mail
  
  config.vm.synced_folder "/tmp", "/codebase", nfs: true

  config.vm.provider "virtualbox" do |v|
    v.memory = 1536
    v.cpus = 2
  end

  config.vm.provision :puppet do |puppet|
    puppet.module_path = "modules"
    puppet.manifests_path = "manifests"
    puppet.manifest_file  = "hashicorp/precise.pp"
  end

  config.vm.provision "shell", path: "install.sh", keep_color: true, run: "always"


end
