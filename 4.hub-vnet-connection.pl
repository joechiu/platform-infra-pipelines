#!/usr/bin/perl

use strict;
use Data::Dumper;
use lib '.';
use config;

my $c = new config;

printf "Connect VHub %s -> %s with Hub %s\n", rg, vnet, loc;

my $cmd = sprintf qq(sh '$root'/bin/vhub-vnet-connections.sh %s %s %s), rg, loc, vnet;
print "$cmd\n";
# system $cmd;

