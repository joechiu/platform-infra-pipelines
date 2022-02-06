#!/usr/bin/perl

use strict;
use Data::Dumper;
use lib '.';
use config;

my $c = new config(env => 'qa');
# $c->init;

printf "Connect VHub %s -> %s in Hub %s\n", mrg, mvnet, loc;

my $cmd = sprintf qq(sh '$root'/bin/vhub-vnet-connections.sh %s %s %s), mrg, loc, mvnet;
print "$cmd\n";
# system $cmd;

