#!/bin/bash

env=${1:-"delme"}
reg=${2:-"uk"}
abs=$(realpath "$0")
dir=$(dirname "$abs")

cd "$dir"/../

"$dir"/../bin/drawit.sh cli

# az account set --subscription "Non-Production Subscription"
perl 3.private-dns-link.pl $env $reg

