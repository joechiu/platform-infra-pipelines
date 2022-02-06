#!/bin/bash

rg=$1
echo "az group delete -n $rg --no-wait --yes"
az group delete -n $rg --no-wait --yes 
