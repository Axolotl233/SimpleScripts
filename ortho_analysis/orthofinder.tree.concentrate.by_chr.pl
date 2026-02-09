#! perl

use warnings;
use strict;
use File::Basename;
use Bio::SeqIO;

if(scalar @ARGV < 2){
    print STDERR "usage perl $0 \$dir \$ref_file [\$prefix]\n";
    exit;
}

my $dir = shift;
my $ref = shift;
my $prefix = shift;
$prefix//="cds";

my %h;
open IN,'<',$ref;
while(<IN>){
    chomp;
    my @l = split/\t/;
    $h{$l[0]} = $l[2];
}
close IN;


my %s;
my @fs = sort {$a cmp $b} grep {/$prefix.align.fa.trim$/} `find $dir`;
for my $f(@fs){
    chomp $f;
    my $n = basename dirname $f;
    my $s_obj = Bio::SeqIO -> new (-file => $f , -format => "fasta");
    while(my $s_io = $s_obj -> next_seq){
        my $id = $s_io -> display_id;
        my $seq = $s_io -> seq;
	my $chr = $h{$n};
        $s{$chr}{$id} .= $seq;
    }
}

for my $k1 (sort {$a cmp $b} keys %s){
    open O,'>',"$k1.fa";
    for my $k2 (sort {$a cmp $b} keys %{$s{$k1}}){
	print O ">$k2\n";
	print O "$s{$k1}{$k2}\n";
    }
    close O;
}
