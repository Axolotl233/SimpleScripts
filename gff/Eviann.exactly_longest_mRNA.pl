#!perl

use warnings;
use strict;
use Bio::SeqIO;
use File::Basename;

if(scalar @ARGV != 2){
    print STDERR "USAGE : perl $0 \$protein \$clean_gff\n";
    exit;
}

my $fa = shift;
my $gff = shift;
my %h;
my %r2;

my $s_obj = Bio::SeqIO-> new(-file => $fa);
while(my $s_io = $s_obj->next_seq){
    my $id = $s_io -> display_id;
    my $seq = $s_io -> seq;
    my $len = $s_io -> length;
    #LOC_00007451-mRNA-1
    (my $rna = $id) =~ s/-mRNA-\d+//;
    $h{$rna}{$id} = $len;
    $r2{$rna} = 1;
}
my %r;
for my $k1 (sort {$a cmp $b} keys %h){
  D:for my $k2 (sort {$h{$k1}{$b} <=> $h{$k1}{$a} || $a cmp $b} keys %{$h{$k1}}){
      $r{$k2} = 1;
	last D;
  }
}
open IN,'<',$gff;
while(<IN>){
    chomp;
    my @l = split/\t/;
    my $id = "NA";
    if($l[2] eq "gene"){
	($id = $l[8]) =~ s/ID=(.*?);.*/$1/;
	print $_."\n" if exists $r2{$id};
    }elsif($l[2] eq "mRNA"){
	($id = $l[8]) =~ s/ID=(.*?);Parent.*/$1/;
	print $_."\n" if  exists $r{$id};
    }elsif($l[2] eq "exon"){
	($id = $l[8]) =~ s/Parent=(.*?);.*/$1/;
	print $_."\n" if  exists $r{$id};
    }elsif($l[2] eq "CDS"){
        ($id = $l[8]) =~ s/Parent=(.*?);.*/$1/;
	print $_."\n" if exists $r{$id};
    }
}
