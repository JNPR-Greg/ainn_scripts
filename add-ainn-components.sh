#!/bin/bash

apstra_server=""
apstra_user=""
apstra_pass=""
auth_token=""

template_prefix="./templates"

dev_profiles="dp-dcs-7060dx5-64s.json"
logical_dev="ld-4x100g.json"
if_maps="if_map-dcs-7060dx5-64s__aos-64x100-2.json if_map-qfx5230-64cd__aos-64x100-2.json"
racks="rack-ainn-compute.json rack-ainn-services.json rack-ainn-storage.json"

###
### Defining some functions first
###

get_auth_token () {
  auth_token=`curl -s -k --location --request POST "https://$apstra_server/api/user/login" --header 'Content-Type: application/json' --data-raw "{
    \"username\": \"$apstra_user\",
    \"password\": \"$apstra_pass\"
  }" | awk '{print $2}' | sed s/[\"\,]//g`
  echo -e "\nReceived auth token:  $auth_token \n"
}

prompt_missing_opts() {
  if [ -z $apstra_server ]; then
    read -p "Server name/IP (optionally ending with :portNumber if not 443): " apstra_server
  fi
  if [ -z $apstra_user ]; then
    read -p "Username for API calls: " apstra_user
  fi
  if [ -z $apstra_pass ]; then
    read -sp "Password for API user: " apstra_pass
    echo \n
  fi
}

###
### Now we run
###

while getopts ":s:u:p:h" option; do
  case $option in
    s)
      apstra_server="$OPTARG"
      ;;
    u)
      apstra_user="$OPTARG"
      ;;
    p)
      apstra_pass="$OPTARG"
      ;;
    *)
      echo "Usage: [add-ainn-components.sh -s server_name/ip -u api_user -p user_password]"
      exit 1
      ;;
  esac
done

prompt_missing_opts

get_auth_token
if [ $auth_token = "Invalid" ]; then
    echo -e "Failed to get an auth token.  Quitting.\n\n"
    exit 1
fi

echo "Adding logical devices..."
for ld in $logical_dev; do
    data=`cat $template_prefix/$ld `
    curl -k --location --request POST "https://$apstra_server/api/design/logical-devices" \
      --header "AUTHTOKEN: $auth_token" \
      --header "Content-Type: application/json" \
      --data-raw "$data"
    echo -e "\n"
done

echo "Adding device profiles..."
for p in $dev_profiles; do
    data=`cat $template_prefix/$p `
    curl -k --location --request POST "https://$apstra_server/api/device-profiles" \
      --header "AUTHTOKEN: $auth_token" \
      --header "Content-Type: application/json" \
      --data-raw "$data"
    echo -e "\n"
done

echo "Adding interface maps..."
for im in $if_maps; do
    data=`cat $template_prefix/$im `
    curl -k --location --request POST "https://$apstra_server/api/design/interface-maps" \
      --header "AUTHTOKEN: $auth_token" \
      --header "Content-Type: application/json" \
      --data-raw "$data"
    echo -e "\n"
done

echo "Adding rack types..."
for r in $racks; do
    data=`cat $template_prefix/$r `
    curl -k --location --request POST "https://$apstra_server/api/design/rack-types" \
      --header "AUTHTOKEN: $auth_token" \
      --header "Content-Type: application/json" \
      --data-raw "$data"
    echo -e "\n"
done
