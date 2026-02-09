#! perl

use warnings;
use strict;
use File::Basename;

my $dir = shift;
my %h;
my @s;

my @fs = sort {$a cmp $b} grep {/cds.count.txt$/} `find $dir`;
for my $f (@fs){
    chomp $f;
    (my $n = basename $f) =~ s/\.cds\.count\.txt//;
    open IN,'<',$f;
    while(<IN>){
	chomp;
	my @l = split/\t/;
	$h{$l[0]}{$n} = $l[1];
    }
    push @s,$n;
}
print "gene\t";
print join"\t",@s;
print "\n";
for my $k (sort {$a cmp $b} keys %h){
    print $k;
    for my $t (@s){
	if(exists $h{$k}{$t}){
	    print "\t$h{$k}{$t}";
	}else{
	    print "\tNA";
	}
    }
    print "\n";
}
