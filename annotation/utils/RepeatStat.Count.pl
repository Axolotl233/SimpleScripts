#! perl

use warnings;
use strict;

if(@ARGV != 2){
    print "USAGE: perl $0 \$f \$genomesize\n";
    exit;
}

my $f = shift;
my $g = shift;
my %h;
open IN,'<',$f;
while(<IN>){
    chomp;
    my @l = split/\t/;
    $h{$l[3]} += ($l[2] - $l[1] + 1);
}
close IN;

for my $k(sort {$a cmp $b} keys %h){
    my $r = sprintf("%.3f",($h{$k}/$g) * 100);
    print "$k\t$h{$k}\t$r\n";
}
