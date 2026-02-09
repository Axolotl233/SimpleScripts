#! perl

use warnings;
use strict;
use File::Basename;

if(scalar @ARGV < 1){
    print STDERR "USAGE: perl $0 Orthogroups.GeneCount.tsv [count] [0,1,...,sp_num-1]\n\n";
    print STDERR "       delete one species and check the OG of rest species whether is [count, default: 1] copy\n";
    print STDERR "       return the number of OGs\n";
    print STDERR "       specific column, comma separate\n";
    exit;
}
my %h;
my %b;

my $f = shift;
my $g = shift;
$g //= 1;
my $sp_b = shift;
$sp_b //= "NA";

open IN, '<', $f;
(my $f_n = basename $f) =~ s/(.*)\..*/$1/;

my $f_header = readline IN;
chomp $f_header;
my @sp = (split/\t/,$f_header);
shift @sp;
pop @sp;
my $sp_n = scalar @sp;

while(<IN>){
    chomp;
    my @l = split/\t/;
    for(my $i = 1;$i < @l-1;$i ++){
	$h{$l[0]}{$i-1} = $l[$i];
    }
}
close IN;
open O,'>',"$f_n.del_sample.OG.txt";

if($sp_b eq "NA"){
    for (my $i = 0;$i < @sp;$i ++){
	my $d = 0;
	for my $k1(sort {$a cmp $b} keys %h){
	    my %c;
	    for my $k2 (sort {$a <=> $b} keys %{$h{$k1}}){
		if ($k2 != $i){
		    my $n = $h{$k1}{$k2};
		    $c{$n} += 1;
		}
	    }
	    if(exists $c{$g}){
		if($c{$g} == ($sp_n - 1)){
		    if($h{$k1}{$i} != $g){
			print O "$k1\t$sp[$i]\n";
			$d += 1;
		    }
		}
	    }
	}
	print "$sp[$i]\t$d\n";
    }
}else{
    my @sp_bs = (split/,/,$sp_b);
    my $sp_bn = scalar @sp_bs;
    $b{$_} = 1 for @sp_bs;
    my $d = 0;
    for my $k1(sort {$a cmp $b} keys %h){
	my %c;
	for my $k2 (sort {$a <=> $b} keys %{$h{$k1}}){
	    if(! exists $b{$k2}){
		my $n = $h{$k1}{$k2};
		$c{$n} += 1;
	    }
	}
	if(exists $c{$g}){
	    if($c{$g} == ($sp_n - $sp_bn)){
		my $jud = 0;
		for my $sp_bss (@sp_bs){
		    $jud = 1 if $h{$k1}{$sp_bss} == $g;
		}
		if($jud == 0){
		    $d += 1;
		    my @p;
		    push @p , $sp[$_] for @sp_bs;
		    print O"$k1\t";
		    print O join",",@p;
		    print O "\n";
		}
	    }
	}
    }
    print "$sp_b\t$d\n";
}		
close O;
