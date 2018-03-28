source /etc/mailinabox.conf
source setup/functions.sh # load our functions

## Setup to convert Mail-in-a-box install to SIAB
echo "Starting conversion from Mail-in-a-box to Server-in-a-box..."
echo "Confirming apt is updated..."
hide_output apt-get update

## Start with LXC.:

echo "Checking if LXC is installed..."

if [ ! -f /usr/bin/lxc ]; then
	echo "Installing lxc (Linux Containers)..."
	apt_install lxc
fi

## Install LWP:

echo "Checking if LWP is installed..."

if [ ! -f /usr/bin/lwp ]; then
	echo "Installing lwp (LXC Web Panel)..."
	curl -s https://packagecloud.io/install/repositories/claudyus/LXC-Web-Panel/script.deb.sh | sudo bash
	#sed -i 's/xenial/trusty/g' /etc/apt/sources.list.d/claudyus_LXC-Web-Panel.list
	hide_output apt-get update
	apt_install lwp
	cp /etc/lwp/lwp.example.conf /etc/lwp/lwp.conf
	echo ""
	echo "Be sure to check /etc/lwp/lwp.conf and change to your liking..!"
fi


## Install shellinabox

echo "Checking if shellinabox is installed..."

if [ ! -f /usr/bin/shellinabox ]; then
	echo "Installing shellinabox (Javascript Shell)..."
	apt_install shellinabox
fi

## Install webmin

echo "Checking if webmin is installed..."

if [ ! -f /usr/bin/webmin ]; then
	echo "Installing webmin (Web Management)..."
	echo "Adding webmin repos..."
	echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list
	wget http://www.webmin.com/jcameron-key.asc -O /root/temp.asc
	apt-key add /root/temp.asc
	echo "Update apt again..."
	hide_output apt-get update
	echo "Install webmin (for real this time)..."
	apt_install webmin
fi

## Allow firewall here.
## Default Ports
ufw_allow 10000
ufw_allow 5000
ufw_allow 4200
## Default LXC Network
ufw allow from 10.0.3.0/24
ufw allow to 10.0.3.0/24
