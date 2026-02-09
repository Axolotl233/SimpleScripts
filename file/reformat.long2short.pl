#! perl

use warnings;
use strict;
use MLoadData;
use Getopt::Long;

my ($s1,$s2,$c1,$c2);
GetOptions(
    'c1=s' => \$c1,
    'c2=s' => \$c2,
    's1=s' => \$s1,
    's2=s' => \$s2,
    );
$c1 //= 0;
$c2 //= 1;
$s1 //= "\t";
$s2 //= ",";

if(@ARGV < 1){
    print STDERR "USAGE : perl $0 --s1 [\\t] --s2 [,] \$f \n";
    exit;
}
my $f = shift;
my %h;
my @ls = MLoadData::load_from_file($f);
for (@ls){
    next unless length $_;
    my @l = split/$s1/,$_;
    push @{$h{$l[$c1]}},$l[$c2];
}

for my $k (sort {$a cmp $b} keys %h){
    print "$k\t";
    my %t;
    $t{$_} = 1 for @{$h{$k}};
    print join"$s2",sort {$a cmp $b} keys %t;
    print "\n";
}
