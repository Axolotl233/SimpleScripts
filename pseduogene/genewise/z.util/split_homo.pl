#! perl

use warnings;
use strict;

my $f = shift;
open IN,'<',$f;
my %h;
while(<IN>){
    chomp;
    my @l = split/\t/;
    if(exists $h{$l[1]}{$l[0]}{$l[8]}){
	print STDERR "duplicate blast : $l[1]\t$l[0]\n";
	exit;
    }
    $h{$l[1]}{$l[0]}{$l[8]} = $_;
}
close IN;

mkdir "homo.split" if !-e "homo.split";
for my $k1 (sort {$a cmp $b} keys %h){
    mkdir "homo.split/$k1" if !-e "homo.split/$k1";
    for my $k2 (sort {$a cmp $b} keys %{$h{$k1}}){
	open O,'>',"homo.split/$k1/$k2.split.txt" or die "$!";
	for my $k3(sort {$a <=> $b} keys %{$h{$k1}{$k2}}){
	    print O "$h{$k1}{$k2}{$k3}\n";
	}
	close O;
    }
}
