#!/bin/bash

# ADAV Scripts collection by DuckProjects.Net
# SSH Configuration for Debian

# Create SSH user with his directory
sudo useradd -m $SSHUSER 
adduser $SSHUSER ssh

echo "$SSHUSER:$SSHPASS" | chpasswd

# Replace default port 22 by port selected by user
OLDPORT=$(cat /etc/ssh/sshd_config | grep "Port ")
rpl "$OLDPORT" "Port $SSHPORT" /etc/ssh/sshd_config

# Write to ADAV installation report
echo "You can access SSH on through port $SSHPORT from $SSHALLOWEDRANGE with \"$SSHUSER\" and the pass you specified." >> $BASEDIR/ADAV_install.report	

if [ "$SSHROOTDIS" = "y" ]; then
# Disable SSH login with a root account
	rpl "PermitRootLogin yes" "PermitRootLogin no" /etc/ssh/sshd_config
	# Allow only SSH user to connect
	echo "AllowUsers $SSHUSER" >> /etc/ssh/sshd_config
	# Write to ADAV installation report
	echo "Root access has been disabled. You can access ssh using only \"$SSHUSER\"." >> $BASEDIR/ADAV_install.report
	echo "" >> $BASEDIR/ADAV_install.report
fi

# Restrict SSH access to IP/IP range selected by user
iptables -A INPUT -p tcp --dport $SSHPORT -m state --state NEW -s $SSHALLOWEDRANGE -j ACCEPT

# Finally, restart the service
service sshd restart

echo "End of SSH Managment script"
