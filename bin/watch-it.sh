#!/bin/bash

path_filename="$(cd "$(dirname "$0")"; pwd -P)/$(basename "$0")"
root=$(dirname $path_filename)

M=$1

GF='["Name","Location","Status"],(.[] | select(.name | test("-delme|-qa|-uat|-test|-stage|-prod")) | [.name,.location,.properties.provisioningState]) | @csv'
GF='["Name","Location","Status"],(.[] | select(.name | test("-ohqapps|-iac")) | [.name,.location,.properties.provisioningState]) | @csv'
HF='["Name","Status"],(.[] | select(.name | test("-ohqapps|-iac")) | [.name,.provisioningState]) | @csv'

echo "RG Status:"
if [ -z "$M" ]; then
  az group list | jq -r "$GF" | $root/csv-new-table
else
  az group list | jq -r "$GF" | $root/csv-table
fi

echo 
echo "VHub Connection Status:"

# az account set --subscription "Networking"

for loc in australiaeast uksouth westus3
do
  echo "Hub $loc:"
  if [ -z "$M" ]; then
    az network vhub connection list --vhub-name vhub-$loc-001 -g rg-net-vwan-001 | jq -r "$HF" | $root/csv-new-table
  else
    az network vhub connection list --vhub-name vhub-$loc-001 -g rg-net-vwan-001 | jq -r "$HF" | $root/csv-table
  fi
done

# az account set --subscription "Non-Production Subscription"
