## -- FIRST RELEASE WILL BE SUBMITTED SOON --
# ADAV - Auto Deploy Anonymous VPN


Auto Deploy Anonymous VPN on Debian-based OS.

### ADAV Scripts collection purpose
ADAV will help you setup and configure the required utilities in order to deploy a complete Anonymous VPN solution, based on OpenVPN, in few minutes.



### Requirements

- A server with (a fresh install of) Debian 9.
- SSH Access on this server
- 5 minutes

ADAV has not been tested on other platforms but it may work for all Debian-based OS (X-K-L-Ubuntu, Raspbian, BackTrack, Kali, ...)

If you successfully ran this script under other Debian-based OS, please let me know as I will update the supported OS list.

### Features
- Set up  your VPN from a fresh Debian install with only SSH and root access by just running one command line
- Securize SSH access to the server
- Local DNS resolver for users connected to VPN
- Blacklist malware/ads domains (at DNS level) - block most ads on smartphone apps
- Can host a page/website accessible only for users conected to VPN
- Access the webserver through a custom domain name


## Utilities installed/used by ADAV
The following softwares are used by ADAV to set up the server :
#### Bind9
Bind9 is a simple DNS server. ADAV configures Bind in order to process all DNS queries coming from VPN LAN only (10.8.0.0/24). ADAV add a blacklist file to Bind configuration in order to filters out any subdomains of known adware or malware domains.
> The blacklist file is issued from the ["dns-zone-blacklist" oznu's project](https://github.com/oznu/dns-zone-blacklist) hosted on github.

#### OpenVPN
OpenVPN is an Open Source VPN server. 
> The script openvpn-install.sh used by ADAV is a modified version of ["OpenVPN-install" Angristan's project](https://github.com/Angristan/OpenVPN-install) hosted on github. This is a very good script to easily configure OpenVPN on most UNIX-based OS. Use this script instead of ADAV if you just want to set up a standalone OpenVPN server.

#### Iptables
Iptables is a configuration utility for Netfilter. ADAV will ask you few questions at startup in order to set some firewall rules to restrict access to some services and enhance server security.
> /!\ Warning /!\\\
> ADAV don't keep eventual previous firewalls rules applied. Be careful when running the script under a production environment.

#### Nginx (optional)
Nginx is a fast and light Webserver. ADAV will ask you if you want to setup a local Webserver (accessible only by users connected on the VPN) in order to host a page/website.
> This webserver can be used to host a file containing informations about services accessible through the VPN connection.




## Installation
### From a fresh debian install

From a fresh Debian 9 install, just upload "ADAV.zip" in the /home/ folder of your server and execute the following command line as ROOT :

> sudo apt-get update;sudo apt-get upgrade;sudo apt-get install unzip;cd /home/;unzip ADAV.zip;cd ADAV/;chmod +x run_me_to_install_ADAV.sh;./run_me_to_install_ADAV.sh

Answer questions asked by the script and ... Voila !

### Classic installation
- Unzip ADAV.zip somewhere on your server : "unzip ADAV.zip" if not installed : "sudo apt-get install unzip"
- Make the installation script executable : "chmod +x run_me_to_install_ADAV.sh"
- Execute the script as root user : "./run_me_to_install_ADAV.sh"
- Answer some questions
- Done !

### Manage VPN users
When running ADAV, the script will ask you for a first VPN user to create and will output an "ovpn" client file. If you want to add/remove VPN users, execute the "openvpn-install.sh" script after ADAV installation has been completed.
> cd /home/ADAV/openvpn\
> ./openvpn-install.sh

### Refresh bind blacklist file
To refresh the file of blacklisted domains used by bind, execute the "bind-mgmt.sh" script with the "refresh" option after ADAV installation has been completed.
>cd /home/ADAV/bind\
>./bind-mgmt.sh refresh


## Enhancements - To Be Done

- ENHANCEMENT : Add support for other OS (not Debian-based)
- TO BE FIXED : nameserver bug in bind-mgmt.sh
- TO BE FIXED : Port 68 UDP -> Bind DNS Server ? / Port 953 TCP -> ?
- TO BE FIXED : Identify the SSH port and open it to the Internet through iptables when SSh user not created by the script
- ENHANCEMENT : Add function to keep previous iptables records
- README : (Add Tips & Tricks to enhance server anonimity/security)

New ideas welcome !


## ADAV Clients tests
ADAV configuration has been tested with a .ovpn file on these clients :
- Ubuntu 16.04 LTS using openvpn client
- Android 8.0.0 with "OpenVPN Connect" apk  (PlayStore)=> Disable "DNS fallback" option and enable "Seamless tunnel".

No problems have been identified. If you got some, please report.

## Anonimity/Security enhancments Tips & Tricks
- Customize the reverse DNS of your server/VPS (generally on your hoster webmanager)


> DuckProjects.Net
