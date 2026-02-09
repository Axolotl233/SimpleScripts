#! perl

use warnings;
use strict;
use Math::Combinatorics;
use List::Util qw/sample shuffle/;

if(scalar @ARGV < 3){
    print STDERR "USAGE: perl $0 Orthogroups.GeneCount.tsv \$info_file \$class_order [class1,class2,..] \$sample_size[100]\n";
    exit;
}

my $f1 = shift;
my $f2 = shift;
my $cc = shift;
my @ccs = split/,/,$cc;
my $tt = shift;
$tt //= 200;

my %c;
open IN,'<',$f2;
while(<IN>){
    chomp;
    my @l = split/\t/;
    push @{$c{$l[1]}} , $l[0];
}
close IN;

open IN,'<',$f1;
my $first = readline IN;
my @head = split/\t/,$first;
pop @head;
my @sp = @head;
shift @sp;
my %h;
while(<IN>){
    chomp;
    my @l = split/\t/;
    pop @l;
    for(my $i = 1;$i < @l;$i ++){
	$h{$l[0]}{$head[$i]} = $l[$i];
    }
}
close IN;

my $n = 1;
my @spa = ();
for my $ct (@ccs){
    my @spt = @{$c{$ct}};
    my $spn = scalar @spt;

    for(my $i = 1;$i <= $spn;$i += 1){
	my @sp_com = combine($i,@spt);
	my $com_n = scalar @sp_com;
	if($com_n > $tt){
	    @sp_com = sample $tt, @sp_com;
	}
	for my $t (@sp_com){
	    my $pan_n = 0;
	    my $core_n = 0;
	    my @sps = (@{$t},@spa);
	    for my $k(keys %h){
		my $j = 1;
		my $q = 0;
		for my $tmp_sp (@sps){
		    $j = $j * $h{$k}{$tmp_sp};
		    $q = $q + $h{$k}{$tmp_sp};
		}
		$pan_n += 1 if $q != 0;
		$core_n += 1 if $j != 0;
	    }
	    print "$n\tpan\t$pan_n\t$ct\n";
	    print "$n\tcore\t$core_n\t$ct\n";
	}
	$n += 1;
    }
    @spa = (@spa,@spt);
}
    
