#! perl

use warnings;
use strict;

if(scalar @ARGV != 2){
    print STDERR "USAGE: perl $0 \$homo \$paf\n";
    exit;
}

my $f1 = shift;
my $f2 = shift;

my %h;

open IN,'<',$f1;
while(<IN>){
    chomp;
    my @l = split/\t/;
    $h{"$l[0]-$l[1]"} = 1;
}
close IN;

open IN,'<',$f2;
while(<IN>){
    chomp;
    my @l = split/\t/;
    print $_."\n" if exists $h{"$l[0]-$l[5]"};
}
close IN;
