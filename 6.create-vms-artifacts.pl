#!/usr/bin/perl

use strict;
use JSON;
use lib '.';
use Data::Dumper;
use lib '.';
use config;

my $c = new config;
$c->NONPROD;

sub vars_update;
sub ssh_data;

my $rg = rg();
my $ws = '/tmp/workspace';
my $loc = loc;
my $tfvar = 'terraform.tfvars';
my $hostfile = 'hosts';
my $varsfile = 'vars.yml';
my $varfile = 'variables.tf';

my $h = {
  "rabbitmq" => [
    {
      "disk_size" => 5,
      "postfix" => "%s",
      "prefix" => "rabbitmq",
      "snet" => snet(APP),
      "sshdata" => 1,
      "size" => "Standard_B2ms",
      "stype" => "Standard_LRS",
      "rgid" => "1"
    }
  ],
  "teamcity" => [
    {
      "disk_size" => 5,
      "postfix" => "%s",
      "prefix" => "teamcity",
      "snet" => snet(APP),
      "sshdata" => 1,
      "size" => "Standard_B2ms",
      "stype" => "Standard_LRS",
      "rgid" => "1"
    }
  ],
  "mssql" => [
    {
      "disk_size" => 5,
      "postfix" => "%s",
      "prefix" => "mssql",
      "snet" => snet(DB),
      "sshdata" => 1,
      "size" => "Standard_B2ms",
      "stype" => "Standard_LRS",
      "rgid" => "1"
    }
  ],
  "docker" => [
    {
      "size" => "Standard_B2ms",
      "stype" => "Standard_LRS",
      "rgid" => "1",
      "disk_size" => 5,
      "postfix" => "%s",
      "sshdata" => 1,
      "snet" => snet(MGMT),
      "prefix" => "iac",
    }
  ],
  "mariadb" => [
    {
      "rgid" => "1",
      "size" => "Standard_B2ms",
      "stype" => "Standard_LRS",
      "snet" => snet(DB),
      "sshdata" => 1,
      "prefix" => "mariadb",
      "postfix" => "%s",
      "disk_size" => 5,
    }
  ],
  "tentacle" => [
    {
      "rgid" => "1",
      "size" => "Standard_B2ms",
      "stype" => "Standard_LRS",
      "snet" => snet(DB),
      "sshdata" => 1,
      "prefix" => "tentacle",
      "postfix" => "%s",
      "disk_size" => 5,
    }
  ],
  "app" => [
    {
      "snet" => snet(APP),
      "prefix" => "app",
      "disk_size" => 5,
      "postfix" => "%s",
      "rgid" => "1",
      "sku" => "2019-Datacenter",
      "size" => "Standard_B2ms",
      "stype" => "Standard_LRS",
    }
  ],
  "web" => [
    {
      "snet" => snet(APP),
      "prefix" => "web",
      "disk_size" => 5,
      "postfix" => "%s",
      "rgid" => "1",
      "sku" => "2019-Datacenter",
      "size" => "Standard_B2ms",
      "stype" => "Standard_LRS",
    }
  ],
  "ip-app" => [
    {
      "snet" => snet(APP),
      "prefix" => "app",
      "disk_size" => 5,
      "postfix" => "%s",
      "rgid" => "1",
      "sku" => "2019-Datacenter",
      "size" => "Standard_B2ms",
      "stype" => "Standard_LRS",
    }
  ],
  "ip-web" => [
    {
      "snet" => snet(APP),
      "prefix" => "web",
      "disk_size" => 5,
      "postfix" => "%s",
      "rgid" => "1",
      "sku" => "2019-Datacenter",
      "size" => "Standard_B2ms",
      "stype" => "Standard_LRS",
    }
  ],
};

`[ -d $ws ] || mkdir -p $ws`;

foreach my $vm ( keys %$h ) {
  my $count = 0;
  foreach my $hh( @{$h->{$vm}} ) {
    $hh || next;
    my $idx = sprintf "%02d", ++$count;
    my $k = $hh->{prefix}.$idx;
    printf "Generate VM $vm - %s codes... ", vm $hh->{prefix};
    my $wsdir = "$ws/$vm/$k";
    `mkdir -p $wsdir`;
    `cp -rf $vm/* $wsdir/.`;
    $hh->{instance_count} = $count || $idx;
    $hh = hh $hh, $count;
    if (-e "$wsdir/ansible") {
      `cp $hostfile $wsdir/ansible/`;
      `echo "[$hh->{prefix}]" >> $wsdir/ansible/$hostfile`;
      `echo "$hh->{hosts}" >> $wsdir/ansible/$hostfile`;
      `echo "sshname: $hh->{hosts}" > $wsdir/ansible/$varsfile`;
      `echo "env: $hh->{hosts}" >> $wsdir/ansible/$varsfile`;
    }
    my @vars = keys %$hh;
    open VAR, "> $wsdir/tf/$varfile";
    foreach my $v (@vars) {
      print VAR qq(variable "$v" {}\n\n);
    }
    close VAR;
    open FILE, "> $wsdir/tf/$tfvar";
    foreach my $p ( keys %$hh ) {
      print FILE qq($p = "$hh->{$p}"\n);
    }
    close FILE;
    print "Done!\n";
  }
}

