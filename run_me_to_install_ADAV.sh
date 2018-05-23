#!/bin/bash

# ADAV Scripts collection by DuckProjects.Net
# Install ADAV script
# Run as root with "./run_me_to_install_ADAV.sh"

### Clear console history and set constants
clear
BASEDIR="$( cd "$(dirname "$0")" ; pwd -P )"

# Create ADAV install report file
touch $BASEDIR/ADAV_install.report
echo "ADAV Installation report" >> $BASEDIR/ADAV_install.report
echo "======================================" >> $BASEDIR/ADAV_install.report

export BASEDIR

### Welcome message
echo "*** ADAV - Auto Deploy Anonymous VPN ***"
echo "(github.com/DuckProjects/Auto-Deploy-Anonymous-VPN)"
echo ""
echo "This script will deploy and help you to configure the following softs:"
echo "Required :"
echo "      Bind9, The well-known DNS resolver (ADAV - bind-mgmt.sh)"
echo "      OpenVPN, The Open Source VPN (github.com/Angristan/OpenVPN-install)"
echo "      Iptables, for Netfilter firewall configuration (ADAV - iptables-config.sh)"
echo ""
echo "Optional :"
echo "      Nginx, The light & fast WebServer (ADAV - webserver-config.sh)"
echo ""
read -n1 -r -p "Press any key to continue..."
echo ""
echo "I have to know a little more about the configuration you need"
echo "Just have to answer some questions. Press ENTER if you agree with default values"
echo ""
echo ""

### Ask user for options to deploy
# Choose to secure SSH access or not
echo "SSH user configuration (OPTIONAL):"
echo "======================================"
echo "If you access your server through SSH with port 22 and user \"root\", it is better to choose \"y\" for following option."
echo "It will create a new SSH user, asking you for username + pass, and restrict SSH access to this user only."
read -p "Create new SSH user (y/n) ? " -e -i y SSHCONFIG
echo""
echo""

# Choose to install WebServer for VPN users or not
echo "Nginx installation (OPTIONAL):"
echo "======================================"
echo "If \"y\" option choosed, a webserver accessible only from the VPN LAN will be deployed."
echo "You can use this webserver to share informations about services which can be accessed through this VPN connection."
read -p "Install Nginx Webserver (y/n) ? " -e -i y NGINXINSTALL
# Add a domain name for connected users ?
if [ "$NGINXINSTALL" = "y" ]; then
	echo ""
	echo "Please enter below the domain name you want to access the 10.8.0.1 Webserver"
	echo "Example: typing \"domain.vpnlan\" result in accessing the server through http://domain.vpnlan"
	read -p "Which domain name to use ? " -e -i domain.vpnlan VPNDOMAIN
	export VPNDOMAIN
fi
echo""
echo""


### Ask user for configuration
# Choose SSH user
if [ "$SSHCONFIG" = "y" ]; then
	echo "You choose to create a new SSH user !"
	echo "SSH Configuration"
	echo "======================================"
	echo "Choose username of the ONLY user allowed to access this server through SSH:"
	read -p "User for SSH : " -e -i sshuser SSHUSER
	
	# Ask user to type password of SSH user
	read -p "Type password for $SSHUSER : " -e SSHPASS
	
	# Ask user to retype password of SSH user
	read -p "Retype password for $SSHUSER : " -e SSHREPASS
	
	# Re ask for password if pass and confirmation don't match
	while [[ "$SSHPASS" != "$SSHREPASS" ]]; do
		echo ""
		echo "Passwords differs ! please retry below..."
		# Ask user to type password of SSH user
		read -p "Type password for $SSHUSER : " -e SSHPASS
		# Ask user to retype password of SSH user
		read -p "Retype password for $SSHUSER : " -e SSHREPASS
	done
		
	# Choose SSH port
	echo ""
	echo "Choose the SSH port (better avoid 22 to improve security):"
	read -p "SSH port: " -e -i 1414 SSHPORT
	
	# Disable root login
	echo ""
	read -p "Disable SSH root login (and restrict access to \"$SSHUSER\" only) ?: " -e -i y SSHROOTDIS
	
	# Restrict SSH access
	echo ""
	echo "Choose the IP/IP range from which SSH can be accessed."
	echo "/!\\ ! WaRnInG ! /!\\"
	echo "Don't change the following setting unless you know what you are doing."
	echo "Bad config can lead to an unaccessible server."
	read -p "Allow SSH access from (IP or IP range) : " -e -i 0.0.0.0/0 SSHALLOWEDRANGE
	
	# Export all vars to retrieve them from the ssh user mgmt script
	export SSHUSER
	export SSHPASS
	export SSHPORT
	export SSHROOTDIS
	export SSHALLOWEDRANGE
fi

# Restrict ping answer
echo ""
echo "Ping Configuration"
echo "======================================"
echo "Choose the locations from which this server can be pinged."
read -p "Allow ping from 0.0.0.0/0 (Internet) ? " -e -i n PINGALLOWNET
read -p "Allow ping from 10.8.0.0/24 (VPN LAN) ? " -e -i y PINGALLOWVPN

export PINGALLOWNET
export PINGALLOWVPN

### INSTALL START
echo ""
echo ""
echo "ADAV will now delpoy the VPN with the selected options. A summary will be reported at the end of the installation"
echo "It will ask you a few more questions (OpenVPN configuration) during install process"
read -n1 -r -p "Press any key to start ADAV install..."
# Install utilities
apt-get install rpl -y

# Configure iptables
cd $BASEDIR/iptables/
chmod +x iptables-config.sh
/bin/bash iptables-config.sh

# Create a new SSH user
if [ "$SSHCONFIG" = "y" ]; then
	cd $BASEDIR/ssh/
	chmod +x create-ssh-user.sh
	/bin/bash create-ssh-user.sh
# If SSH user not created, open port 22 to all Internet -- ENHANCMENT : Open SSH port defined on sshd_config
elif [ "$SSHCONFIG" = "n" ]; then
	iptables -A INPUT -p tcp --dport 22 -m state --state NEW -s 0.0.0.0/0 -j ACCEPT
fi

# Install bind and initialize blacklist with a few entries
cd $BASEDIR/bind/
chmod +x bind-mgmt.sh
/bin/bash bind-mgmt.sh install

# Refresh blacklist with the full file hosted on github
cd $BASEDIR/bind/
/bin/bash bind-mgmt.sh refresh

# Create "root" folder
#sudo mkdir /home/root/

# Install OpenVPN roadwarrior mode
cd $BASEDIR/openvpn/
chmod +x openvpn-install.sh
/bin/bash openvpn-install.sh

# Install and configure Nginx for local webserver
if [ "$NGINXINSTALL" = "y" ]; then
	cd $BASEDIR/nginx/
	chmod +x webserver-config.sh
	/bin/bash webserver-config.sh
fi

## These lines were originally located in "bind-mgmt.sh". See comments in file for details.
# Updating resolv.conf file
OLDNAMESERVER=$(cat /etc/resolv.conf | grep nameserver)
NEWNAMESERVER="nameserver 127.0.0.1"
rpl "$OLDNAMESERVER" "$NEWNAMESERVER" /etc/resolv.conf
service bind9 restart

echo ""
echo ""
echo ""
echo "ADAV has performed all operations needed to set up your VPN !"
echo ""
cat $BASEDIR/ADAV_install.report
echo ""
echo "These informations have been written to ADAV/ADAV_install.report."

