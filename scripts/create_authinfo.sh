#!/bin/bash
# Script to create the authinfo file for the CAS connection

cat << 'EOF' > ~/.authinfo
host gelenv-lts-live.race.sas.com user sastest2 password lnxsas
host gelenv-stable-live.race.sas.com user sastest2 password lnxsas
EOF

# Set the file permissions
chmod 600 ~/.authinfo
