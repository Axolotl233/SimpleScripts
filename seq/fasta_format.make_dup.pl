#! perl

use warnings;
use strict;
use Bio::SeqIO;
use File::Basename;

my $ref = shift or die "need ref";
my $fa = shift;
my $col1 = shift;
my $col2 = shift;
$col1 //= 0;
$col2 //= 1;

open R,'<',$ref or die "$!";
my %h;
my %oo;
while(<R>){
    next if /^$/;
    chomp;
    (my $old,my $new) = (split/\t/,$_)[$col1,$col2];
    push @{$h{$old}}, $new;
}
my $seqio_obj = Bio::SeqIO -> new(-file => $fa, -format =>"fasta");
while(my $seq_obj = $seqio_obj -> next_seq){
    my $o_id = $seq_obj -> display_id;
    my $seq = $seq_obj -> seq;
    if(exists $h{$o_id}){
	for my $t (@{$h{$o_id}}){
	    $oo{$t} = $seq;
	}
    }
    print ">$o_id\n$seq\n";
}
print ">$_\n$oo{$_}\n" for sort{$a cmp $b} keys %oo;
