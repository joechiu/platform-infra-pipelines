#!/usr/bin/perl

use strict;
use Data::Dumper;
use lib '.';
use config;

my $c = new config;
$c->nonprod;
printf "VNet %s exists\n", vnet and exit if $c->is_vnet(mvnet);

my $ws = 'workspace';
my $wsdone = 'deployed-workspace';
my $tfvar = 'terraform.tfvars';
my $varfile = 'variables.tf';

`[ -d $ws ] && rm -rf $ws`;
`mkdir -p $ws`;

my $idx = sprintf "%02d", $idx;
print "Generate VNet $env codes\n";
my $wsdir = "$ws/$env";
system "mkdir -p $wsdir";
system "cp -rf ./vnet/tf/* $wsdir/.";
my $h = $c->mrv;
my @vars = keys %$h;
open VAR, "> $wsdir/$varfile";
foreach my $v (@vars) {
  print VAR qq(variable "$v" {}\n\n);
}
close VAR;
open FILE, "> $wsdir/$tfvar";
foreach my $p ( keys %$h ) {
  if ($p =~ /snet|snet_cidr/gi) {
    print FILE qq($p = [$h->{$p}]\n);
  } else {
    print FILE qq($p = "$h->{$p}"\n) if $p !~ /sshdata/g;
  }
}
close FILE;

my $dir = "$root/$ws/$env";
chdir $dir;
print "Deploy virtual network - $h->{vnet}";
system "terraform init";
system "terraform apply -auto-approve";
print "Done!\n";

