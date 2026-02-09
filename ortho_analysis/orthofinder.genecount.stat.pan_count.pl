#! perl

use warnings;
use strict;

if(scalar @ARGV < 1){
    print STDERR "USAGE: perl $0 Orthogroups.GeneCount.tsv \n\n";
    exit;
}

my $f = shift;
open IN,'<',$f;

my $first = readline IN;
my @head = split/\t/,$first;
pop @head;
my @sp = @head;
shift @sp;
my $sp_n = scalar @sp;
my %h;
my %o1;
my %o2;

while(<IN>){
    chomp;
    my @l = split/\t/;
    pop @l;
    my $nn = 0;
    my @p;
    for(my $i = 1;$i < @l;$i ++){
	if($l[$i] != 0){
	    push @p, $head[$i];
	    $nn += 1;
	}
    }
    if($nn == 1){
	$o1{$nn}{$p[0]} += 1;
    }else{
	$o2{$nn} += 1 
    }
}
close IN;

for(my $i = 1;$i <= $sp_n;$i ++){
    if($i == 1){
	for my $k (keys %{$o1{$i}}){
	    print "$i\t$k\t$o1{$i}{$k}\n";
	}
    }else{
	print "$i\tmore\t$o2{$i}\n";
    }
}
