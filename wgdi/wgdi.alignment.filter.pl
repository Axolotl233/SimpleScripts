#! perl

use warnings;
use strict;
use File::Basename;

if(scalar @ARGV < 2){
    print STDERR "USAGE : perl $0 \$homo \$alignment/n";
}


my $homo = shift;
my $f = shift;

(my $n = basename $f) =~ s/(.*)\..*/$1/;

open R,'<',$homo;
my %r;
while(<R>){
    chomp;
    my @l = sort {$a cmp $b} split/\t/;
    my $t = join"-",@l;
    print STDERR "$t\n";
    $r{$t} = 1;
}
close R;

open IN,'<',$f;
open O,'>',"$n.filter.csv";
while(<IN>){
    chomp;
    my @l = split/,/;
    my @gs;
    for my $g (@l){
	$g =~ s/g.*//;
	push @gs, $g;
    }
    @gs = sort {$a cmp $b} @gs;
    my $t = join"-",@gs;
    print O $_."\n" if (exists $r{$t});
}
close IN;
close O;
