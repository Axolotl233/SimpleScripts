#! perl

use warnings;
use strict;
use Bio::SeqIO;

my $f = shift;
my $o = shift;

open O,'>',$o;

my $s_obj = Bio::SeqIO -> new(-file => $f, -format =>"fasta");
while(my $s_io = $s_obj -> next_seq){
    my $id = $s_io -> display_id;
    my $seq = $s_io -> seq;
    my $len = $s_io -> length;
    my $n = ($seq =~tr/Nn//);
    my $r = 1-($n/$len);
    $r = sprintf("%.3f",$r);
    print O "$id\t$r\n";
}
