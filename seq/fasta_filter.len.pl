#! perl

use Bio::SeqIO;
use strict;
use warnings;

if(scalar @ARGV < 1){
    print STDERR "USAGE : perl $0 \$seq \$length [100]\n";
    exit;
}
my $f = shift;
my $thr = shift;
$thr //= 100;

my $s = Bio::SeqIO -> new (-file => $f , -format => "fasta");

while(my $i = $s -> next_seq){
    my $id = $i -> display_id;
    my $l = $i -> length;
    my $seq = $i -> seq;
    if($l >= $thr){
        print ">$id\n$seq\n";
    }
}
