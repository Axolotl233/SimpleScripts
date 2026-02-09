#! perl

use warnings;
use strict;
use MLoadData;

if(scalar @ARGV != 3){
    print STDERR "USAGE : perl $0 \$chr_length \$chr_adjust \$gff\n";
    exit;
}

my $ref = shift;
my $adjust = shift;
my $bed = shift;

my %ref = MLoadData::load_from_file_hash_content($ref,"\t",0,1);
my %chr = MLoadData::load_from_file_hash($adjust);

open IN,'<',$bed;
while(<IN>){
    chomp;
    if(/^#/){
	print $_."\n";
	next;
    }
    next if !length $_;
    my @l = split/\t/;
    if(exists $chr{$l[0]}){
        my $t_len = $ref{$l[0]};
	my $len = $l[4] - $l[3];
        my $r_s = $t_len - ($l[4] - 1);
        my $r_e = $r_s + $len;
	$l[3] = $r_s;
	$l[4] = $r_e;
	if($l[6] eq "+"){
	    $l[6] = "-";
	}else{
	    $l[6] = "+";
	}
        print join"\t",@l;
    }else{
        print $_;
    }
    print "\n";
}
