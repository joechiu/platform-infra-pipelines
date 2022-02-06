
clear
. ~/azure/conf

env=$1
reg=$2
pid=$3
n=$4

# read -n 1 -s -r -p "Delete Env Instance $yellow$env $reg$reset. Press any key to continue"

while true
do
  trap "kill $pid; exit" INT
  (( n -= 1 ))
  printf "\rDeleting Env Instance $yellow$env $reg$reset in $n seconds... Ctrl-C to quit!"
  [ "$n" == "0" ] && { echo; exit; }
  sleep 1
done

