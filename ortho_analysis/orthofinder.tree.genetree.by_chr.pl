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
my @fs = sort {$a cmp $b} grep {/$prefix.align.fa.trim.treefile$/} `find $dir`;
for my $f(@fs){
    chomp $f;
    my $n = basename dirname $f;
    open IN,'<',$f;
    while(<IN>){
	my $chr = $h{$n};
        $s{$chr} .= $_;
    }
}

for my $k1 (sort {$a cmp $b} keys %s){
    open O,'>',"$k1.trees";
    print O $s{$k1};
    close O;
}
