#! perl

use warnings;
use strict;
use Bio::SeqIO;
use File::Basename;

if(scalar @ARGV < 1){
    print STDERR "USAGE : perl $0 \$fa \$sep [.] [id format : xxxxxxxxx[sep]xx\]\n";
    exit;
}

my $fa = shift;
my $sep = shift;
$sep //= ".";

my %h;

my $c_obj = Bio::SeqIO -> new(-file => $fa, -format => "fasta");
while(my$c_io = $c_obj -> next_seq){
    my $id = $c_io -> display_id;
    my $len = $c_io -> length;
    my $seq = $c_io -> seq;
    my @g_ids = split/\Q$sep\E/,$id;
    #print join"\t",@g_ids;exit;
    my $g_id = $g_ids[0];
    #(my $g_id = $id) =~ s/(.*?)$sep.*/$1/;
    push @{$h{$g_id}} , [$id,$len,$seq];
}

my %new;
for my $k (sort {$a cmp $b} keys %h){
    my @gene = @{$h{$k}};
    @gene = sort {$b->[1] <=> $a->[1]} @gene;
    my $id = $gene[0] -> [0];
    my $s = $gene[0] -> [2];
    print ">$id\n$s\n";
}
