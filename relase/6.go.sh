#!/bin/bash

env=${1:-"delme"}
reg=${2:-"uk"}
abs=$(realpath "$0")
dir=$(dirname "$abs")

"$dir"/../bin/drawit.sh peanut
"$dir"/../bin/drawit.sh bye

