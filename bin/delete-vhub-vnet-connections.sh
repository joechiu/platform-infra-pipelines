
rg=$1
loc=$2
vnet=$3

[ -z $rg ] && { echo "Error: missing resource group name!"; exit 1; }
[ -z $vnet ] && { echo "Error: missing virtual network name!"; exit 1; }

vhub=vhub-$loc-001
vwrg=rg-net-vwan-001

echo "Delete conn-$vnet in $vhub"

# az account set --subscription "Networking"

az network vhub connection delete -n conn-$vnet --vhub-name $vhub -g $vwrg --no-wait --yes

# az account set --subscription "Non-Production Subscription"


