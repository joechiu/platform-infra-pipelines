#!/bin/bash

env=${1:-"delme"}
reg=${2:-"uk"}
abs=$(realpath "$0")
dir=$(dirname "$abs")

"$dir"/../bin/drawit.sh hello
"$dir"/../bin/drawit.sh azp

rm -rf /tmp/workspace
