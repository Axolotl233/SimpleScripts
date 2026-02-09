#! perl

use warnings;
use strict;
use File::Basename;
use Cwd qw/abs_path getcwd/;

if(scalar @ARGV < 1){
    print STDERR "USAGE : perl $0 \$gff\n";
    exit;
}

my $gff = shift;
(my $n = basename $gff) =~ s/.pseudo_label.gff//;
my $gff_c = $n.".clean.gff";
my $lst = $n.".pseudo.tsv";
my $lst2 = $n.".lncRNA.tsv";
my %h1;
my %h2;
my %h3;
my $h_dir = getcwd();

open IN,'<',$gff;
while(<IN>){
    chomp;
    next if /^#/;
    my @l = split/\t/;
    if($l[2] eq "mRNA"){
	my @t = split/;/,$l[8];
	if($t[-1] eq "pseudo=true"){
	    $t[1] =~ s/Parent=//;
	    $h1{$t[1]} = 1;
	    $t[0] =~ s/ID=//;
	    $h2{$t[0]} = 1;
	}
    }elsif($l[2] eq "lnc_RNA"){
	my @t = split/;/,$l[8];
	$t[1] =~ s/Parent=//;
	$h1{$t[1]} = 1;
	$t[0] =~ s/ID=//;
	$h3{$t[0]} = 1;
    }
}
close IN;

open O1,'>',$gff_c;
open O2,'>',$lst;
open O3,'>',$lst2;
open IN,'<',$gff;

 D:while(<IN>){
     chomp;
     next if /^#/;
     my @l = split/\t/;
     my @t = split/;/,$l[8];
     if($l[2] eq "gene"){
	 $t[0] =~ s/ID=//;
	 next D if exists $h1{$t[0]};
     }elsif($l[2] eq "mRNA"){
	 $t[0] =~ s/ID=//;
	 if(exists $h2{$t[0]}){
	     print O2 "$l[0]\t$l[3]\t$l[4]\t$t[0]\n";
	     next D;
	 }
     }elsif($l[2] eq "exon"){
	 $t[0] =~ s/Parent=//;
	 next D if exists $h2{$t[0]};
	 next D if exists $h3{$t[0]};
     }elsif($l[2] eq "CDS"){
	 $t[0] =~ s/Parent=//;
	 next D if exists $h2{$t[0]};
     }elsif($l[2] eq "lnc_RNA"){
	 $t[0] =~ s/ID=//;
	 print O3 "$l[0]\t$l[3]\t$l[4]\t$t[0]\n";
	 next D;
     }
     print O1 $_."\n";
}
close IN;
close O1;
close O2;
