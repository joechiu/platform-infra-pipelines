#!/usr/bin/perl

use strict;
use Data::Dumper;
use lib '.';
use config;

my $c = new config;

my $zone = dns;
my $rgzone = rgzone;
my $shell = "private-dns.sh";

# link VNet to private DNS
my $p = {
  app => { rg => rg, vnet => vnet },
  iac => { rg => mrg, vnet => mvnet },
};

foreach my $k ( keys %$p ) {
  my $rg = $p->{$k}->{rg};
  my $vnet = $p->{$k}->{vnet};
  my $link = dlink $vnet;
  print "Create Zone $zone\n" if not $c->is_dns($zone);
  $c->create_dns($rgzone, $zone) if not $c->is_dns($zone);
  print "$link exists, skipped" if $c->is_link($rgzone, $zone, $link);
  next if $c->is_link($rgzone, $zone, $link);
  print "Create a link '$link' from $zone to $vnet\n";
  my $cmd = qq(sh '$root'/bin/$shell $zone $rgzone $rg $vnet $link);
  # print system $cmd;
  print $cmd;
  print " - Done!\n";
}

