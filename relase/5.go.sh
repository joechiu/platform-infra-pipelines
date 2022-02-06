#!/bin/bash

env=${1:-"delme"}
reg=${2:-"uk"}
abs=$(realpath "$0")
dir=$(dirname "$abs")

cd "$dir"/../

"$dir"/../bin/drawit.sh cli

perl 5.hub-mgmt-vnet-connection.pl $env $reg

