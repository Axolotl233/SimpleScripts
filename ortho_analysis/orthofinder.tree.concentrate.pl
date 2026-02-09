#! perl

use warnings;
use strict;
use File::Basename;
use Bio::SeqIO;

if(scalar @ARGV < 1){
    print STDERR "usage perl $0 \$dir \$prefix [cds]\n";
    exit
}

my $dir = shift;
my $prefix = shift;
$prefix//="cds";

my %s;
my @fs = sort {$a cmp $b} grep {/$prefix.align.fa.trim$/} `find $dir`;
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
