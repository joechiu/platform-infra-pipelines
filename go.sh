
env=${1:-"delme"}
reg=${2:-"uk"}
tmp=./workspace

[ -d $tmp ] && rm -rf $tmp

echo "Deploy $env $reg environment"
sleep 5

az account set --subscription "Non-Production Subscription"

perl 1.create-rg-vnet-snet.pl $env $reg
perl 2.create-rg-mgmt-vnet-snet.pl $env $reg
perl 3.private-dns-link.pl $env $reg
perl 4.hub-vnet-connection.pl $env $reg
perl 5.hub-mgmt-vnet-connection.pl $env $reg
[ -d $tmp ] && rm -rf $tmp
# perl 6.create-vms-artifacts.pl $env $reg

