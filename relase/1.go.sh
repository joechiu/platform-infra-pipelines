#!/bin/bash

env=${1:-"delme"}
reg=${2:-"uk"}
abs=$(realpath "$0")
dir=$(dirname "$abs")

cd "$dir"/../

"$dir"/../bin/drawit.sh terraform

# az account set --subscription "Non-Production Subscription"
perl 1.create-rg-vnet-snet.pl $env $reg

