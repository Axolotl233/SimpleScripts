#! perl

use warnings;
use strict;

if(scalar @ARGV != 2){
    print STDERR "\nThis script used for extract gff based on mRNA name, support gene, mRNA, exon, CDS\n";
    print STDERR "\nUSAGE : perl $0 \$gff \$ref_mnra\n";
    exit;
}

my $f1 = shift;
my $f2 = shift;
my %h;

open IN,'<',$f2;
while(<IN>){
    chomp;
    $h{$_} = 1;
}
close IN;

open IN,'<',$f1;
while(<IN>){
    chomp;
    next if /^#/;
    next if /^\s/;
    my @l = split/\t/;
    if($l[2] eq 'gene'){
	print $_."\n";
    }elsif($l[2] eq "mRNA"){
	$l[8] =~ /ID=(.*?);/;
	next if ! exists $h{$1};
	print $_."\n";
    }elsif($l[2] eq "CDS"){
	$l[8] =~ /Parent=(.*?);/;
	next if ! exists $h{$1};
        print $_."\n";
    }else{
	next;
    }
}
