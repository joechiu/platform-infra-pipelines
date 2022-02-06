
rg1=$1
rg2=$1
v1=$2
v2=$3
pfix=$4

echo "Peering from Virtual Network $v1 to $v2"
name="$v1-$v2"
rvid=$(az network vnet show -g $rg2 -n $v2-$pfix | jq '.id' | sed 's/"//g')
echo $rvid
az network vnet peering create -g $rg1 -n $name --vnet-name $v1-$pfix --remote-vnet $rvid --allow-vnet-access 


