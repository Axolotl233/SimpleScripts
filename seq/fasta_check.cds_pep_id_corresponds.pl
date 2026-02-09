#! perl

use warnings;
use strict;
use Bio::SeqIO;
use File::Basename;

if(scalar @ARGV < 2){
    print STDERR "USAGE : perl $0 \$cds.fa \$pep.fa\n";
    exit;
}

my $f_cds = shift;
my $f_pep = shift;
my %h;

my $c_obj = Bio::SeqIO -> new(-file => $f_cds, -format => "fasta");
while(my$c_io = $c_obj -> next_seq){
    my $id = $c_io -> display_id;
    $h{$id}{cds} = 1;
}

my $p_obj = Bio::SeqIO -> new(-file => $f_pep, -format => "fasta");
while(my$p_io = $p_obj -> next_seq){
    my $id = $p_io -> display_id;
    $h{$id}{pep} = 1;
}

for my $k (keys %h){
    if(exists $h{$k}{cds} && !exists $h{$k}{pep}){
	print "$k\tpep\n";
    }elsif(!exists $h{$k}{cds} && exists $h{$k}{pep}){
	print "$k\tcds\n";
    }
}
