
zone=$1
rg=$2
rg2=$3
vnet=$4
link=$5

echo "-- 1. Private DNS zone - $zone"

echo "-- 2. Link DNS zone to vnets "
vnet=$(az network vnet show -g $rg2 -n $vnet | jq '.id' | sed 's/"//g')

# az account set --subscription "Networking"

az network private-dns link vnet create -g $rg -n $link -z $zone -v $vnet -e true

# az account set --subscription "Non-Production Subscription"

