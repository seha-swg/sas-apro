#!/bin/bash
# This script is used to get the current binary port information from the shared collections
# The binary port information is used for connections to the CAS Servers
# The first step is to get the hostnames from the PSGELSHR README.md

# Clean-up and previous run
rm -Rf ~/working/
mkdir -p ~/working/
rm ~/project/binary-ports.txt

cd ~/working/

# Set the project README URL
README_URL="https://gelgitlab.race.sas.com/GEL/workshops/PSGELSHR-gel-sas-viya-4-shared-environment/-/raw/master/README.md"

# Get the host names
printf "\n\nGetting the Shared Collection host names\n"
echo "lts-host::"$(curl ${README_URL} | grep 'live.lts' | awk -F'gelenv-lts.' '{print $2 }' | awk -F']' '{ print $1 }') | tee -a ~/working/hosts.txt
echo "stable-host::"$(curl ${README_URL} | grep 'live.stable' | awk -F'gelenv-stable.' '{print $2 }' | awk -F']' '{ print $1 }') | tee -a ~/working/hosts.txt

lts_host=$( cat ~/working/hosts.txt | awk -F'lts-host::' '{print $2}')
stable_host=$( cat ~/working/hosts.txt | awk -F'stable-host::' '{print $2}')

printf "\n\nGetting the Shared Collection port numbers\n"
# Get ports from LTS Live, namespace gelenv-lts
lts_server_bin="$(ssh -o StrictHostKeyChecking=no ${lts_host} 'kubectl -n gelenv-lts get svc | grep sas-cas-server-default-bin')"
lts_port=$( echo ${lts_server_bin} | awk -F':' '{print $2}' | awk -F'/' '{print $1}')
echo "lts-port::"${lts_port} | tee -a ~/project/binary-ports.txt

# Get ports from Stable Live, namespace gelenv-stable
stable_server_bin="$(ssh -o StrictHostKeyChecking=no ${stable_host} 'kubectl -n gelenv-stable get svc | grep sas-cas-server-default-bin')"
stable_port=$( echo ${stable_server_bin} | awk -F':' '{print $2}' | awk -F'/' '{print $1}')
echo "stable-port::"${stable_port} | tee -a ~/project/binary-ports.txt

cd ~/project/