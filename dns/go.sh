
rg=rg-dns-australia-001
loc=australiaeast
az group create --name $rg --location $loc

[ -z "$1" ] && env=qa || env=$1

echo "Generate ARM template"
vm=dnsproxy
ansible-playbook -e "vm=$vm env=$env" arm-temp.yml -vvv

echo "Create VM $vm-$env"
res=`az deployment group create --resource-group $rg --template-file /tmp/azuredeploy.json`
ip=`echo $res | jq '.properties.outputs.pip.value' | sed 's/"//g'`
echo "VM created - $ip"

ansible-playbook -e "vm=$vm env=$env ip=$ip" ssh-config.yml -vvv

echo "[dns]" > "host-$env"
echo "$vm-$env" >> "host-$env"

echo "Install DNS forwarder"
ansible-playbook -i host-$env install-dns.yml -vvv
