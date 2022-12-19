#!/bin/bash
# Script to download the order assest (license and certificates)
# 25 July 2022, Updated to pass the cadence name and version
# Run as: get_assets.sh <cadence name> <cadence version>

# Set-up variables
## Orders CLI
VERSION_ORDER_CLI=1.4.0

## Analytics Pro order
#ORDER_NUMBER=9CJZ73
## Analytics Pro Advanced Programming order
ORDER_NUMBER=9CQ73S
CADENCE_NAME=$1
#CADENCE_VERSION=$2
var2=$2


function set-cadence () {
  if [[ $var2 = 'latest' ]] ; then
    echo "Setting Stable cadence version"
    month=$(date +%m)
    # Test for '01' and set to previous year
    if [[ ${month} = '01' ]] ; then
      # Use December for n-1
      year=$(($(date +%Y)))
      year=$((${year} - 1))
      CADENCE_VERSION=${year}.12
    else
      month=$(( ${month}  ))
      month=$(( ${month} - 1 ))
      year=$(date +%Y)
      CADENCE_VERSION=${year}.${month}
    fi
  else
    CADENCE_VERSION=$var2
  fi
  echo "Using Stable cadence version: "${CADENCE_VERSION}
}

function set-lts () {
  # Using LTS-2022.09
  CADENCE_VERSION="2022.09"
  echo "Using cadence version: LTS-"${CADENCE_VERSION}
}

case ${CADENCE_NAME} in
  'lts')
    set-lts
  ;;
  
  'stable')
    set-cadence
  ;;
  
  *)
    printf "\nInvalid input.\n"
    exit 99
  ;;
esac

# Get the orders CLI
URL_ORDER_CLI=https://github.com/sassoftware/viya4-orders-cli/releases/download/${VERSION_ORDER_CLI}/viya4-orders-cli_linux_amd64

ansible localhost \
-b --become-user=root \
-m get_url \
-a  "url=${URL_ORDER_CLI} \
    dest=/usr/local/bin/viya4-orders-cli \
    validate_certs=no \
    force=yes \
    owner=root \
    mode=0755 \
    backup=yes" \
--diff

# Set-up API keys for the Orders CLI
echo -n otHGJtno8QGTqys9vRGxmgLOCnVsHWG2 | base64 > /tmp/clientid.txt
echo -n banKYbGZyNkDXbBO | base64 > /tmp/secret.txt
echo "clientCredentialsId= "\"$(cat /tmp/clientid.txt)\" > $HOME/.viya4-orders-cli.env
echo "clientCredentialsSecret= "\"$(cat /tmp/secret.txt)\" >> $HOME/.viya4-orders-cli.env

# Get the license and certificates
printf "\nGetting the Analytics Pro Licnense and Certificates\n\n"

viya4-orders-cli -c $HOME/.viya4-orders-cli.env cer ${ORDER_NUMBER} -p ~/project/assets/ -n SASViyaV4_APro_certs
viya4-orders-cli -c $HOME/.viya4-orders-cli.env lic ${ORDER_NUMBER} ${CADENCE_NAME} ${CADENCE_VERSION} -p ~/project/assets/ -n SASViyaV4_APro_license

printf "\nDownload complete\n\n"
#cd ~/project/assets/
