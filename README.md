# Development setup for ColdFusion 10 on Ubuntu Precise x64

## Requirements

* VirtualBox >= 4.1.x
* Vagrant >= 1.5.x

## What you get

* a virtual machine running 64-bit version of Ubuntu
* Coldfusion 10 fully configured
* custom JDK version
* Apache with mod_jk connector to ColdFusion Server
* a mail server that catches all e-mail sent from ColdFusion
* a web mail client to access all e-mail sent from ColdFusion
* MS core fonts
* SSL self signed certificates

## How to use

*You have to check out the your code base yourself*

Change the `/tmp` path in `Vagrantfile` to point to your local website checkout.

`config.vm.synced_folder "/tmp", "/codebase"`

A NFS share is used on unix based systems but on Windows systems this does not work.   

#### And then...

Download these files:
`https://www.dropbox.com/s/cgmycpeeu7pjelr/ColdFusion_10_WWEJ_linux64.bin?dl=1`
`https://www.dropbox.com/s/96w4ssf89uzx570/jre-7u15-linux-x64.tar.gz?dl=1`
to here:  
`./files/downloads`  

Also, edit the `./files/hosts.txt` file to match your local host names.

Run this command to power up the VM:  
`vagrant up`

Windows users can use the Git Bash shell to run vagrant.

## Access

The Vagrantfile contains the port numbers used, e.g. `http` is accessible via port `:8880`.

ColdFusion admin: [http://localhost:8520/CFIDE/administrator] password: 0000  
Squirrel Webmail: [http://localhost:8880/squirrelmail] (username: vagrant, password: vagrant)  

If you want to run the servers on standard ports such as 80 and 443 you have to use a proxy server on your host machine.

The e-mail is gathered in a `mbox` file located in `./mail`. You can also use Evolution Mail or some other client to access it directly.

