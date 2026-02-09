#! perl

use warnings;
use strict;
use List::Util qw/sum/;

if(scalar @ARGV < 2){
    print STDERR "USAGE: perl $0 Orthogroups.GeneCount.tsv \$ref\n\n";
    exit;
}

my $f2 = shift;
my $f1 = shift;

my %r;
open IN,'<',$f1;
while(<IN>){
    chomp;
    my @l = split/\t/;
    $r{$l[0]} = 1;
}
close IN;

open IN,'<',$f2;
my $f_header = readline IN;
chomp $f_header;
my @sp = (split/\t/,$f_header);
shift @sp;
pop @sp;
my $sp_n = scalar @sp;
my @sp_p;
for my $s(@sp){
    if (exists $r{$s}){
	push @sp_p,$s;
    }
}
print "Orthogroup\t";
print join"\t",@sp_p;
print "\tTotal\n";

while(<IN>){
    chomp;
    my @l = split/\t/;
    my @p;
    for(my $i = 1;$i < @l-1;$i ++){
	my $s = $sp[$i-1];
        if(exists $r{$s}){
	    push @p, $l[$i];
	}
    }
    my $t = sum(@p);
    if($t > 0) {
	print "$l[0]\t";
	print join"\t",@p;
	print "\t$t\n";
    }
}
close IN;
