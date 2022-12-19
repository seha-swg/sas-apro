#!/bin/bash
# Create the HR user and data

# Create the HR /home root folder
sudo rm -Rf /HR-home/
sudo mkdir -p /HR-home/
sudo chmod 775 /HR-home/

# Set-up gatedemo200 as the HR user
sudo useradd gatedemo200 -u 2129800618 -g 3440 -m -d /HR-home/gatedemo200
#sudo usermod -a -G sas,hr gatedemo200
echo "P@ssw0rd" | sudo passwd gatedemo200 --stdin

# Create the HR data folder
sudo mkdir -p /hr-data/
sudo chmod 775 /hr-data/

# Get the dummy HR data
sudo cp ~/PSGEL317-sas-analytics-pro-deployment-and-configuration/files/hr-data/* \
 /hr-data/
# Set permissions to the HR group
#sudo chgrp -R hr /hr-data/
sudo chown -R gatedemo200 /hr-data/

printf "\nSet-up complete\n\n"
