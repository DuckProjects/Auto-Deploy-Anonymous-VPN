#!/bin/bash

# ADAV Scripts collection by DuckProjects.Net
# Nginx installer for Debian
# Install a webserver accessible by VPN users only

# Install bind on Debian/Ubuntu
echo "Installing Nginx..."
apt-get install nginx -y
echo "DONE !"

# Remove default nginx HTML welcome page
echo "Removing default Nginx HTML files"
rm -f /var/www/html/*
echo "DONE !"

# Copy new HTML file(s) to www nginx folder
cp -rv html_files/* /var/www/html/
echo "Webserver has been set up !"

# Add new domain
cp -rv bind_domain_files/custom.zone.file /etc/bind/
echo "$VPNDOMAIN    A        10.8.0.1" >> /etc/bind/custom.zone.file
echo "zone \"$VPNDOMAIN\" { type master; file \"/etc/bind/custom.zone.file\"; };" >> /etc/bind/named.conf.local
OLDSTRING="response-policy { zone \"my.Custom.Domain\"; };"
NEWSTRING="response-policy { zone \"$VPNDOMAIN\"; };"
rpl "$OLDSTRING" "$NEWSTRING" /etc/bind/named.conf.options

# Only allow users connected on the VPN LAN to connect to the webserver
iptables -A INPUT -p tcp --dport 80 -m state --state NEW -s 10.8.0.0/24 -j ACCEPT # Allow VPN users to access local webserver

# Write to ADAV installation report
echo "The local webserver can only be accessed by VPN users through 10.8.0.1 or $VPNDOMAIN" >> $BASEDIR/ADAV_install.report
echo "Webserver files are located in \"/var/www/html/\" folder. A minimal HTML file has been provided to test your access." >> $BASEDIR/ADAV_install.report
