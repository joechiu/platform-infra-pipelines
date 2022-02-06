use Net::IP;

my $cidr = shift || '10.10.254.0';
my $len = shift || 23;

my $ip = new Net::IP("$cidr/$len");
my $nn;
do {
  ++$nn;
  print $ip->ip(), "\n";
} while (++$ip);

print "Total: $nn IP addresses available\n";
