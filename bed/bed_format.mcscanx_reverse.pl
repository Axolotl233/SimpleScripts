#! perl

use warnings;
use strict;
use MLoadData;

if(scalar @ARGV != 3){
    print STDERR "USAGE : perl $0 \$chr_lenth \$chr_adjust \$bed\n";
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
    my @l = split/\t/;
    if(exists $chr{$l[0]}){
	my $t_len = $ref{$l[0]};
	my $len = $l[3] - $l[2];
	my $r_s = $t_len - $l[3];
	my $r_e = $r_s + $len;
	print join"\t",($l[0],$l[1],$r_s,$r_e);
    }else{
	print $_;
    }
    print "\n";
}
