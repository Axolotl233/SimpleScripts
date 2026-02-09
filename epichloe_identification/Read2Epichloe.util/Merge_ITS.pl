#! perl

use warnings;
use strict;
use Bio::SeqIO;
use File::Basename;

my $dir = shift;
my $ff = shift;

print STDERR "$dir:$ff\n";

my @ds = sort {$a cmp $b} grep {/\_/} `ls $dir`;
for my $d (@ds){
    chomp $d;
    my $f = "$d/its.$ff.fasta";
    my $n = basename dirname $f;
    my $s_obj = Bio::SeqIO -> new(-file => $f, -format =>"fasta");
    while(my $s_io = $s_obj -> next_seq){
	my $id = $s_io -> display_id;
	my $seq = $s_io -> seq;
	my $len = $s_io -> length;
	if($len > 0){
	    print ">$n\n$seq\n";
	}
    }
}
