#!/bin/sh

# ADAV Scripts collection by DuckProjects.Net
# Iptables configuration

# /!\ This script doesn't keep previous iptables records /!\
# Make sure no changes have been made in iptables before running this script.

# Flush previous entries
iptables --flush
iptables --delete-chain

### GENERAL CONFIGURATION
# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Enable free use of loopback interfaces
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# All TCP sessions should begin with SYN
iptables -A INPUT -p tcp ! --syn -m state --state NEW -s 10.8.0.0/24 -j DROP

# INPUT configuration
iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT

# Port used by OpenVPN is already open by "openvpn-install.sh" script (from 0.0.0.0/0)
# Port used by SSH is already open by "create-ssh-user.sh" script (from user selected IP/IP range)
# Port used by Webserver may be open by "webserver-config.sh" script (from VPN LAN only)

# Eventually allow ping from Internet
if [ "$PINGALLOWNET" = "y" ]; then
	iptables -A INPUT -p ICMP --icmp-type 8 -s 0.0.0.0/0 -j ACCEPT
fi

# Eventually allow ping from VPN LAN
if [ "$PINGALLOWVPN" = "y" ]; then
	iptables -A INPUT -p ICMP --icmp-type 8 -s 10.8.0.0/24 -j ACCEPT
fi

### Access for users connected on the VPN LAN
iptables -A INPUT -p udp -m udp --dport 53 -s 10.8.0.0/24 -j ACCEPT # Allow UDP DNS query
iptables -A INPUT -p tcp --dport 53 -m state --state NEW -s 10.8.0.0/24 -j ACCEPT # Allow TCP DNS query


# --FIX ME-- What is Port 953 TCP ?
# --FIX ME-- Port 68 UDP : DHCP ?
