#!/bin/bash

# SETUP NODE NETWORK

if [ -n "$1" ]

then

HOST=`hostname`
HOSTNAME_SUFFIX=${HOST:4}

echo "***** Cleaning up old $1 settings *****"

grep -v "$1" /etc/network/interfaces > temp && mv temp /etc/network/interfaces

echo "***** Setting up $1 with STATIC IP *****"

cat <<EOT >> /etc/network/interfaces

auto $1
iface $1 inet static
	address 172.16.3.10$HOSTNAME_SUFFIX
	netmask 255.255.0.0
	gateway 172.16.0.1
	dns-nameservers 8.8.8.8 8.8.4.4

EOT

echo -e "\n***** Network Interfaces Updated ***** \n"
cat /etc/network/interfaces
echo -e "\n***** End Of File ***** \n"

echo -e "***** Bringing up $1 *****"

sudo ifdown $1 && sudo ifup $1

echo -e "\n***** IP Address Information for $1 *****\n"

ip address show $1

echo -e "\n***** Setting up hosts file *****\n"

cat <<EOT >> /etc/hosts

172.16.3.100	master
172.16.3.101	node1
172.16.3.102	node2
172.16.3.103	node3
172.16.3.104	node4
EOT

echo -e "\n***** Hosts File Updated *****\n"

cat /etc/hosts

echo -e "\n***** End Of File *****\n"

echo -e "\nSetup Completed!\n"

else
  echo "Must include network interface as first argument"
  echo "Example: # sudo ./setup_script.sh eth0"
  exit 0
fi

exit 0
