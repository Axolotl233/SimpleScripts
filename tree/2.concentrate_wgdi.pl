#! perl

use warnings;
use strict;
use File::Basename;
use Bio::SeqIO;

my %s;
my @fs = sort {$a cmp $b} grep {/cds.muscle.fa$/} `find split_gene`;
for my $f(@fs){
    chomp $f;
    my $n = basename dirname $f;
    print STDERR $n."\n";
    my $s_obj = Bio::SeqIO -> new (-file => $f , -format => "fasta");
    while(my $s_io = $s_obj -> next_seq){
        my $id = $s_io -> display_id;
        my $seq = $s_io -> seq;
	$s{$id} .= $seq;
    }
}
for my $k (sort {$a cmp $b} keys %s){
    print ">$k\n$s{$k}\n";
}
