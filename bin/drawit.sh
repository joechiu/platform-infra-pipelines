#!/bin/bash

path_filename="$(cd "$(dirname "$0")"; pwd -P)/$(basename "$0")"
path=$(dirname "$path_filename")

cd "$path"
. logos.inc

pic=$1

eval $pic
