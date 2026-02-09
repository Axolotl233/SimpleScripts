#! perl

use warnings;
use strict;

if(@ARGV < 2){
    print STDERR "USAGE : perl $0 Orthogroups.tsv \$go_ref1 \$go_ref2 ... \$go_refn\n";
    exit;
}

my $f1 = shift;

my %h;
for my $f (@ARGV){
    open IN,'<',$f or die "$!";
    while(<IN>){
        chomp;
        my @l = split/\t/,;
        push @{$h{$l[0]}}, @l[1..$#l];
    }
    close IN;
}

open IN,'<',$f1 or die "$!";
readline IN;
while(<IN>){
    chomp;
    my @l = split/\t/;
    my %p;
    for(my $i = 1;$i < @l;$i ++){
        my @t = split/, /,$l[$i];
        for my $g (@t){
            if (exists $h{$g}){
		$p{$_} += 1 for @{$h{$g}};
	    }
        }
        
    }
    print "$l[0]\t";
    print join"\t",sort {$a cmp $b} keys %p;
    print "\n";
}
