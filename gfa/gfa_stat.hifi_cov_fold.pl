#! perl

use warnings;
use strict;

if(@ARGV != 2){
    print STDERR "\nUSAGE: perl $0 \$gfa \$cov_expected\n";
    exit;
}

my $gfa = shift;
my $cov_e = shift;

open IN,'<',$gfa;
while(<IN>){
    chomp;
    next unless /^S/;
    my @l = split/\t/;
    #rd:i:133
    my @t = split/:/,$l[4];
    $t[2] = sprintf("%.4f",($t[2]/$cov_e));
    print "$l[1]\t$t[2]\n";
}
