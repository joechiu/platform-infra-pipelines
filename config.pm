package config;

use strict;
use JSON;
use lib '.';
use POSIX qw/strftime/;
use List::Util qw(first);
use File::Spec;
use Data::Dumper;
use constant E    => 'dev';
use constant R    => 'au';
use constant DB   => 'dbs';
use constant APP  => 'app';
use constant MGMT => 'iac';
use constant IPRG => "rg-australieast-co-ips-001";
use constant NETWORK => qq(az account set --subscription "Azure Automation Demo");
use constant NONPROD => qq(az account set --subscription "Azure Automation Demo");
use vars qw/
  @ISA
  @EXPORT
  $env
  $reg
  $idx
  $root
/;
require Exporter;
@ISA = qw/ Exporter /;
@EXPORT = qw/
  $env $reg $idx $root rg mrg vnet
  mvnet dns dnsrg rgzone dlink DB APP
  MGMT snet loc tag IPRG hosts pip nsg 
  nic ptip vm hostname osdisk exdisk
  is_reg is_env done ssh_data read_json hh
/;

$env = shift || E;
$reg = lc shift || R;
$idx = shift || 1;
$root = File::Spec->rel2abs( $0 );
$root =~ s/\/$0//;

# l -> loc, r -> region, d -> dns, v => vnet, s => snet
my $c = {
  au    => { l => 'australiaeast', r => 'australiaeast', d => 'az.auto.demo.com.au',  v => 10, },
  us    => { l => 'westus3',       r => 'westus3',       d => 'az.auto.demo.com',     v => 20, },
  uk    => { l => 'uksouth',       r => 'uksouth',       d => 'az.auto.demo.co.uk',   v => 30, },
  vnet  => '10.%d.%d.0/24',
  snet  => '10.%d.%d.0/25',
  ssnet => { app => '10.%d.%d.0/25', dbs => '10.%d.%d.128/25', iac => '10.%d.253.224/28', },
  envs  => [ qw( prod qa dev test uat stage delme demo ) ],
  done  => [ qw( qa-au qa-us ) ],
};

sub new {
    my $class = shift;
    my $cc = bless {}, $class;
    my %c = @_;
    map { $cc->{lc($_)} = $c{$_} } keys %c;
    $cc->{errstr} = undef;
    $cc->{err} = [];
    return $cc;
}

sub init {
  my $cc = shift;
  $env = $cc->{env};
}

# subscription networking
sub network {
  my $cc = shift;
  system NETWORK;
}
# subscription non prod
sub nonprod {
  my $cc = shift;
  system NONPROD;
}

# check existence
sub is_vnet {
  my $cc = shift;
  my $vnet = shift;
  my @vnet = `az network vnet list | jq '.[].name'`;
  chomp @vnet;
  return grep /$vnet/, @vnet;
}
sub is_dns {
  my $cc = shift;
  my $dns = shift;
  $cc->network;
  my @zone = `az network private-dns zone list | jq '.[].name'`;
  chomp @zone;
  $cc->nonprod;
  return grep /$dns/, @zone;
}
sub is_link {
  my $cc = shift;
  my $rg = shift;
  my $zone = shift;
  my $link = shift;
  $cc->network;
  my @link = `az network private-dns link vnet list -g $rg -z $zone | jq '.[].name'`;
  chomp @link;
  $cc->nonprod;
  return grep /$link/, @link;
}

# creations
sub create_dns {
  my $cc = shift;
  my $rgzone = shift;
  my $zone = shift;
  $cc->network;
  system "az network private-dns zone create -g $rgzone -n $zone";
  $cc->nonprod;
}

sub region {
  return $c->{$reg}->{r}
}
sub loc {
  return $c->{$reg}->{l}
}
sub dns {
  return "$env.".$c->{$reg}->{d}
}
sub vn2 { # 2nd vnet network number
  return $c->{$reg}->{v}
}

sub is_reg {
  region
}

sub is_env {
  grep { $env eq $_ } @{$c->{envs}};
}

sub done {
  grep /$env-$reg/, @{$c->{done}};
}

# name convention without idx
sub nc {
  sprintf "%s-%s", shift || 'foo', shift || 'bar';
}

# name convention with idx
sub ncidx {
  sprintf "%s-%s-%03d", shift || 'foo', shift || 'bar', $idx;
}

# environment index
sub edx {
  my @env = @{$c->{envs}};
  my $id = first { $env[$_] eq $env } 0..$#env;
  die "Environment ID does not exist!" unless defined $id;
  return $id;
}

sub vnetcidr {
  sprintf $c->{vnet}, vn2, edx;
}

sub snetcidr {
  sprintf $c->{snet}, vn2, edx;
}

sub ssnetcidr {
  my $stype = shift;
  if ($stype !~ /iac/i) {
    sprintf $c->{ssnet}->{$stype}, vn2, edx;
  } else {
    sprintf $c->{ssnet}->{$stype}, vn2;
  }
}

sub mrg {
  sprintf "rg-$env-%s-iac-%03d", region, $idx;
}

sub mvnet {
  sprintf "vnet-$env-%s-iac-%03d", region, $idx;
}

sub rg {
  sprintf "rg-$env-%s-co-%03d", region, $idx;
}

sub vnet {
  sprintf "vnet-$env-%s-co-%03d", region, $idx;
}

sub snet {
  # sprintf "snet-%s-%03d", shift, $idx;
  ncidx 'snet', shift;
}

# short subnet name
sub ssnet {
  sprintf "snet-%s-%03d", shift, $idx;
}

sub tag {
  sprintf "Infrastructure %s %s", uc $env, ucfirst region;
}

sub dnsrg {
  sprintf "rg-net-%s-dns-%03d", region, $idx;
}

sub rgzone {
  sprintf "rg-net-%s-dns-%03d", region, $idx;
}

sub dlink {
  sprintf "lnk-%s", shift;
}

sub pip {
  sprintf "pip-%s-$env-$reg-%03d", shift, $idx;
}

sub nsg {
  sprintf "nsg-%s-%03d", shift, $idx;
}

sub nic {
  sprintf "nic-%s-%03d", shift, $idx;
}

sub ptip {
  sprintf "ptip-%s-%03d", shift, $idx;
}

sub vm {
  sprintf "%s", shift;
}

sub hostname {
  sprintf "%s", shift;
}

sub hosts {
  sprintf '%s-%s-%s%03d', $env, $reg, shift, $idx;
}

sub osdisk {
  sprintf "%s-osdisk", shift;
}

sub exdisk {
  sprintf "%s-exdisk", shift;
}

sub read_json {
  my $c = shift;
  open FILE, shift || die "Error: $@";
  my $jstr = join '', <FILE>;
  close FILE;
  my $j;
  eval { $j = from_json($jstr); };
  return { error => $@ } if $@;
  $j;
}

# create management rg and vnet
sub mrv{ 
  my $c = shift;
  my $h = {};
  my @type = qw( iac );
  $h->{rg} = mrg;
  $h->{vnet} = mvnet;
  $h->{snet} = join ',', map { '"'.snet($_).'"' } @type;
  $h->{vnet_cidr} = join ',', map { (ssnetcidr $_) } @type;
  $h->{snet_cidr} = join ',', map { '"'.(ssnetcidr $_).'"' } @type;
  $h->{postfix} = $env;
  $h->{location} = loc;
  $h->{tag} = tag;
  $h->{instance_count} = $idx;
  return $h;
}

# create rg and vnet
sub rv { 
  my $c = shift;
  my $h = {};
  my @type = qw( app dbs );
  $h->{rg} = rg;
  $h->{vnet} = vnet;
  $h->{snet} = join ',', map { '"'.snet($_).'"' } @type;
  $h->{vnet_cidr} = vnetcidr;
  $h->{snet_cidr} = join ',', map { '"'.(ssnetcidr $_).'"' } @type;
  $h->{postfix} = $env;
  $h->{location} = loc;
  $h->{tag} = tag;
  $h->{instance_count} = $idx;
  return $h;
}

sub ssh_data {
  my @pub;
  open FILE, "/etc/keys/ohq-$env.pub";
  @pub = <FILE>;
  close FILE;
  chomp @pub;
  join '', @pub;
}

sub hh {
  my $hh = shift;
  my $count = shift || $idx;

  $hh->{postfix} = $env;
  if ($hh->{prefix} =~ /iac/ig) {
    $hh->{rg} = mrg;
    $hh->{vnet} = mvnet;
  } else {
    $hh->{rg} = rg;
    $hh->{vnet} = vnet;
  }

  $hh->{tag} = tag;
  $hh->{iprg} = IPRG;
  $hh->{location} = loc;
  $hh->{pip} = pip $hh->{prefix};
  $hh->{nsg} = nsg $hh->{prefix};
  $hh->{nic} = nic $hh->{prefix};
  $hh->{ptip} = ptip $hh->{prefix};
  $hh->{vm} = vm $hh->{prefix};
  $hh->{hostname} = hostname $hh->{prefix};
  $hh->{osdisk} = osdisk $hh->{prefix};
  $hh->{exdisk} = exdisk $hh->{prefix};
  $hh->{hosts}  = hosts $hh->{prefix};
  $hh->{sshdata} = ssh_data if $hh->{sshdata};
  return $hh;
}

1;
