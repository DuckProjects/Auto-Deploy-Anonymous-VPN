#!/bin/bash

# ADAV Scripts collection by DuckProjects.Net
# Bind installer for Debian

if [ "$EUID" -ne 0 ]; then
	echo "Sorry, you need to run this script as root"
	exit 1
fi

if [ "$1" = "install" ]; then
	## INSTALL section
	# Install bind on Debian/Ubuntu
	echo "BEGIN Bind9 install"
	apt-get install bind9 -y
	
	## FIX ME ? -> These lines have been reported at the end of the main ADAV install script
	## Symptoms : Can't retrieve entries when downloading OpenVPN
	# Updating resolv.conf file
	#OLDNAMESERVER=$(cat /etc/resolv.conf | grep nameserver)
	#NEWNAMESERVER="nameserver 127.0.0.1"
	#rpl "$OLDNAMESERVER" "$NEWNAMESERVER" /etc/resolv.conf
	
	# Copy bind zone files
	echo "Copying files to bind conf folders..."
	rm -f /etc/bind/named.conf.local
	rm -f /etc/bind/named.conf.options
	cp -rv conf_files_for_bind/* /etc/bind/
	echo "DONE !"
	echo "--- End of installation ! Restart the script with the \"refresh\" argument."
	
elif [ "$1" = "refresh" ]; then	
	## REFRESH section
	# Calcultate the checksum of the actual blacklist file
	echo "Calculating actual blacklist file checksum..."
	RAWCALCULATEDCHECKSUM=$(echo -n foobar | sha256sum /etc/bind/zones.blacklist)
	CALCULATEDCHECKSUM=$(echo $RAWCALCULATEDCHECKSUM| cut -d' ' -f 1)
	echo "DONE !"
	
	# Get the checksum of the blacklist checksum file hosted on github
	echo "Getting the content of the checksum file hosted on gitHub..."
	rm -f /etc/bind/zones.blacklist.checksum
	wget -P /etc/bind/ https://raw.githubusercontent.com/oznu/dns-zone-blacklist/master/bind/zones.blacklist.checksum
	DOWNLOADEDCHECKSUM=$(cat /etc/bind/zones.blacklist.checksum)
	echo "DONE !"
	
	# Compare the 2 checksums and download the new blacklist file if not different
	if [ "$CALCULATEDCHECKSUM" = "$DOWNLOADEDCHECKSUM" ]; then
		echo "It's a Checksum match ! No need to download a new blacklist file !"
	else
		echo "Checksum dismatch. The new blacklist will be downloaded from github."
		# Stop the services
		echo "Stopping OpenVPN and bind..."
		service openvpn stop
		service bind9 stop
		echo "DONE !"
			
		# Download new blacklist file in "temp" directory
		echo "Downloading blacklist file in temporary folder..."
		if [ ! -e /etc/bind/temp ]; then
			mkdir /etc/bind/temp
		fi
		
		wget -P /etc/bind/temp https://raw.githubusercontent.com/oznu/dns-zone-blacklist/master/bind/zones.blacklist
		echo "DONE !"
		
		# Calculate checksum of the new blacklist file
		echo "Computing new blacklist file checksum..."
		RAWNEWCHECKSUM=$(echo -n foobar | sha256sum /etc/bind/temp/zones.blacklist)
		NEWCHECKSUM=$(echo $RAWNEWCHECKSUM| cut -d' ' -f 1)
		echo "DONE !"
		
		# If the new blacklist file checksum match with the downloaded checksum,
		# backup old file, move new file on the right directory and delete "temp" folder
		if [ "$NEWCHECKSUM" = "$DOWNLOADEDCHECKSUM" ]; then
			echo "New file checksum match with github hosted checksum ! Applying new conf..."
			
			# Backup old blacklist file
			if [ -e /etc/bind/zones.blacklist.bak ]; then
				rm -f /etc/bind/zones.blacklist.bak
			fi
			cp /etc/bind/zones.blacklist /etc/bind/zones.blacklist.bak
			rm -f /etc/bind/zones.blacklist
			
			# Move new file to right location
			mv /etc/bind/temp/zones.blacklist /etc/bind/zones.blacklist
			
			# Delete "temp" folder
			rm -rf /etc/bind/temp
			echo "DONE ! A backup file has been created (zones.blacklist.bak)"	
		
		else
			echo "--- New file checksum mismatch with github hosted checksum ! Nothing done..."
		fi
		
		# Start the services
		echo "Starting OpenVPN and bind services..."
		service bind9 start
		service openvpn start
		echo "DONE !"
	fi
	
	echo "--- End of blacklist update !"
	
elif [ "$1" = "remove" ]; then	
	## REMOVE section
	apt-get autoremove --purge -y bind9
	
else
	echo "No or bad arguments have been passed to the script. Plz choose between \"install\", \"refresh\" or \"remove\""
fi

exit 0;

