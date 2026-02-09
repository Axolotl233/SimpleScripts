#! perl

use warnings;
use strict;

if (@ARGV < 2){
    print STDERR "USAGE : perl $0 alignment.csv convert.txt ...\n";
    exit;
}

my $f_a = shift;

my %h;
for my $f(@ARGV){
    open IN,'<',$f;
    while(<IN>){
        chomp;
        my @l = split/\t/;
        $h{$l[0]} = $l[1];
    }
    close IN;
}

open IN,'<',$f_a;
while(<IN>){
    chomp;
    my @l = split/,/,$_,-1;
    for(my $i = 0;$i < scalar @l;$i ++){
	if(exists $h{$l[$i]}){
	    $l[$i] = $h{$l[$i]};
	}
    }
    print join",",@l;
    print "\n";
}
