#! perl

use warnings;
use strict;
use File::Basename;

my %h;
open IN,'<',shift;
while(<IN>){
    chomp;
    my @l = split/\t/;
    $h{$l[0]} = $l[1];
}
close IN;

my $dir = shift;
my @fs = sort {$a cmp $b} grep{/.lst/} `find $dir`;
for my $f (@fs){
    chomp $f;
    (my $n = basename $f) =~ s/_mapped.fq.lst//;
    my $d = `wc -l $f`;
    $d =~ s/\s.*//;
    $d = $d * 2;
    my $r = sprintf("%.4f",($d*100)/$h{$n});
    print "$n,$h{$n},$d,$r\n";
}
	
