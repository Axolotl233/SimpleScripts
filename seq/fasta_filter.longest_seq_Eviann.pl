#! perl

use warnings;
use strict;
use Bio::SeqIO;
use File::Basename;

if(scalar @ARGV != 1){
    print STDERR "USAGE : perl $0 \$seq\n";
    exit;
}

my $seq = $ARGV[0];
my %h;

my $c_obj = Bio::SeqIO -> new(-file => $seq, -format => "fasta");
while(my$c_io = $c_obj -> next_seq){
    my $id = $c_io -> display_id;
    my $seq = $c_io -> seq;
    #LOC_00007451-mRNA-3
    (my $id_desc = $id) =~ s/(.*-mRNA)-\d+/$1/; 
    my $len = $c_io -> length;
    push @{$h{$id_desc}} , [$id,$len,$seq];
}

for my $k (sort {$a cmp $b} keys %h){
    my @gene = @{$h{$k}};
    @gene = sort {$b->[1] <=> $a->[1]} @gene;
    my $id = $gene[0] -> [0];
    my $len = $gene[0] -> [1];
    my $seq = $gene[0] -> [2];
    print ">$id\n$seq\n";
}

