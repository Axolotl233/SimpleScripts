#! perl

use warnings;
use strict;

if(scalar @ARGV != 2){
    print STDERR "USAGE : perl $0 \$busco_full_table_before \$busco_full_table_after\n";
    exit;
}

my $f1 = shift;
my $f2 = shift;

my %h;

open IN,'<',$f1;
while(<IN>){
    chomp;
    next if /^#/;
    my @l = split/\t/,$_;
    if($l[1] ne "Missing"){
	push @{$h{$l[0]}{$l[1]}},$l[2];
    }
}
close IN;

open IN,'<',$f2;
while(<IN>){
    chomp;
    next if /^#/;
    my @l = split/\t/,$_;
    if($l[1] eq "Missing"){
	if(exists $h{$l[0]}){
	    for my $k2 (sort {$a cmp $b} keys %{$h{$l[0]}}){
		print "$l[0]\t$k2\t";
		print join",",@{$h{$l[0]}{$k2}};
		print "\n";
	    }
	}
    }
}
