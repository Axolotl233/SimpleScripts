#! perl

use warnings;
use strict;

if(@ARGV < 2){
    print STDERR "USAGE : perl $0 Orthogroups.tsv \$file_ref1 \$file_ref2 ... \$file_refn\n";
    exit;
}

my $f1 = shift;

my %h;
for my $f (@ARGV){
    open IN,'<',$f or die "$!";
    while(<IN>){
	chomp;
	my @l = split/\t/,;
	$h{$l[0]} = $l[1];
    }
    close IN;
}

open IN,'<',$f1 or die "$!";
while(<IN>){
    chomp;
    my @l = split/\t/;
    for(my $i = 1;$i < @l;$i ++){
	my @t = split/, /,$l[$i];
	for my $g (@t){
	    $g = $h{$g} if exists $h{$g};
	}
	$l[$i] = join", ",@t;
    }
    print join"\t",@l;
    print "\n";
}
