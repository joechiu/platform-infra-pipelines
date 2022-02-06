
rg=$1
loc=$2
vnet=$3

[ -z $rg ] && { echo "Error: missing resource group name!"; exit 1; }
[ -z $vnet ] && { echo "Error: missing virtual network name!"; exit 1; }

vhub=vhub-$loc-001
vwrg=rg-net-vwan-001


rvid=$(az network vnet show -g $rg -n $vnet | jq '.id' | sed 's/"//g')

echo "Link $vhub to $vnet - conn-$vnet"

# az account set --subscription "Networking"

az network vhub connection create -n conn-$vnet --vhub-name $vhub -g $vwrg --remote-vnet $rvid --no-wait

# az account set --subscription "Non-Production Subscription"


