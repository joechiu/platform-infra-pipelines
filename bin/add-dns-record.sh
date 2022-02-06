
name=$1
ip=$2

echo "-- 1. Private DNS zone - $zone"
rg=rg-networking-nonprod-001
zone=nonprod.az.officehq.com.au
# zone=foo.bar.com

echo "-- Create an additional DNS record"
az network private-dns record-set a add-record \
  -g $rg \
  -z $zone \
  -n $name \
  -a $ip

