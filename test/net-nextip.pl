use Net::IP;

my $cidr = '10.20.0.128';
my $cidr = shift || '10.20.0.0';
# class length
my $len = shift || 25;

my $ip = print_all("$cidr/$len");

$lastip = $ip->last_ip();
print "last ip ('$cidr/$len'): ", $lastip, "\n";
$ip = new Net::IP ("$lastip + 1") || die Net::IP::Error();
$nextip = $ip->last_ip();
print "next ip: ", $nextip, "\n";

$cidr = "$nextip/$len";
print "\nNext IP Range - $cidr\n";
print_all($cidr);

sub print_all {
  my $cidr = shift;
  my $ip = new Net::IP ($cidr) or die Net::IP::Error();
  print "IP  : ".$ip->ip()."\n";
  print "Sho : ".$ip->short()."\n";
  print "Bin : ".$ip->binip()."\n";
  print "Int : ".$ip->intip()."\n";
  print "Mask: ".$ip->mask()."\n";
  print "Last: ".$ip->last_ip()."\n";
  print "Len : ".$ip->prefixlen()."\n";
  print "Size: ".$ip->size()."\n";
  print "Type: ".$ip->iptype()."\n";
  print "Rev:  ".$ip->reverse_ip()."\n";
  $ip;
}
