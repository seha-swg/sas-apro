#!/bin/bash
# Script to create the local users and their /home folders
#
# As the Linux host doesn't have a SSSD configuration to the GEL RACE AD
# The local user definitons have to be created to match the info in AD.

# Create the /userHome root folder
sudo rm -Rf /userHome/
sudo mkdir -p /userHome/
sudo chmod 775 /userHome/

# Create the sas Group
sudo groupadd -g 3440 sas

# Create the users using the AD UID and GID info
sudo useradd gelviyaadmin -u 2147483647 -g 3440 -m -d /userHome/gelviyaadmin
sudo useradd gatedemo001 -u 2129800419 -g 3440 -m -d /userHome/gatedemo001
sudo useradd gatedemo002 -u 2129800420 -g 3440 -m -d /userHome/gatedemo002
sudo useradd gatedemo003 -u 2129800421 -g 3440 -m -d /userHome/gatedemo003

# Set the passwords the same as the AD user
echo "P@ssw0rd" | sudo passwd gelviyaadmin --stdin
echo "P@ssw0rd" | sudo passwd gatedemo001 --stdin
echo "P@ssw0rd" | sudo passwd gatedemo002 --stdin
echo "P@ssw0rd" | sudo passwd gatedemo003 --stdin
