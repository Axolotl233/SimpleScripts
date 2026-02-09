#! perl

use warnings;
use strict;
use MLoadData;
use File::Basename;

if(scalar @ARGV < 1) {
    print STDERR "perl $0 \$dir\n";
    exit;
}

my $dir = shift;
my @fs = sort {$a cmp $b} grep{/chromosomes.report$/} `find $dir`;

for my $f (@fs){
    chomp $f;
    (my $n = basename dirname $f);
    open IN,'<',$f;
    while(<IN>){
	chomp;
	next if /^#/;
	$_ =~ s/^\s+//;
	print "$_\t$n\n";
    }
    close IN;
}
