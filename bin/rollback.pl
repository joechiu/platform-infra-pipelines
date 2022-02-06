#!/usr/bin/perl

use strict;
use Data::Dumper;
use lib '.';

use config;

my $c = new config;
my $timeout = 5;

chdir "$root/bin";

exit printf "Environment %s not exists!\n", $env unless is_env;
exit printf "Region %s not exists!\n", $reg unless is_reg;
exit printf "Platform %s is done and cannot be rollback!\n", done if done;

system "bash time-message.sh $env $reg $$ $timeout";

printf "\nRollback platform %s $reg!\n", $env;

# `az account set --subscription "Non-Production Subscription"`;

foreach my $rg (rg, mrg) {
  print "-- Remove $rg in the background\n";
  my $cmd = qq(sh rm-rg.sh $rg);
  system $cmd;
  if ($?) {
    print "Error: $?\n";
  } else {
    print " - Done!\n";
  }
}

print "-- Delete Hub Connections in the background\n";
my $cmd = sprintf "sh $root/bin/delete-vhub-vnet-connections.sh %s %s %s", rg, loc, vnet;
print "$cmd\n";
system $cmd;

print "-- Delete IaC Hub Connections in the background\n";
my $cmd = sprintf "sh $root/bin/delete-vhub-vnet-connections.sh %s %s %s", mrg, loc, mvnet;
print "$cmd\n";
system $cmd;


