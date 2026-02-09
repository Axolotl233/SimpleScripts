#! perl

use strict;
use File::Basename;
use Cwd qw/abs_path getcwd/;

if(scalar @ARGV < 1){
    print STDERR "USAGE : perl $0 \$gff\n";
    exit;
}
my $gff = shift;
open IN,'<', $gff;
my $c1 = 0;
my $c2 = 0;
while(<IN>){
    chomp;
    my @l = split/\t/;
    my @t = split/;/,$l[8];
    if($l[2] eq "mRNA"){
	$c1 = 0;
	$c2 = 0;
	print $_."\n"
    }elsif($l[2] eq "CDS"){
	$c1 += 1;
	(my $mrna = $t[0]) =~ s/Parent=//;
	$l[8] = "ID=$mrna.CDS.$c1;$t[0]";
	print join"\t",@l;
	print "\n";
    }elsif($l[2] eq "exon"){
	$c2 += 1;
        (my $mrna = $t[0]) =~ s/Parent=//;
        $l[8] = "ID=$mrna.exon.$c2;$t[0]";
        print join"\t",@l;
        print "\n";

    }else{
	print $_."\n";
    }
}
close IN;
