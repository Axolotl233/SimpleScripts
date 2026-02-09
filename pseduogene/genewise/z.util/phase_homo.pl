#! perl

use warnings;
use strict;

my $f = shift;
open IN,'<',$f;
while(<IN>){
    chomp;
    my @l = split/\t/;
    if($l[8]>$l[9]){
	my $tmp = $l[8];
	$l[8] = $l[9];
	$l[9] = $tmp;
    }
    print join"\t",@l;
    print "\n";
}
