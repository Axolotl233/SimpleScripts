#! perl

use warnings;
use strict;

open R,'<',shift;
my %r;
while(<R>){
    chomp;
    my @l = split/\t/;
    $r{$l[0]} = $l[1];
}
close R;

open IN,'<',shift;
while(<IN>){
    chomp;
    my @l = split/\t/;
    $l[4] = $r{$l[0]};
    print join"\t",@l;
    print "\n";
}
close IN;

