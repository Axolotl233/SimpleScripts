#! perl

use warnings;
use strict;

if(scalar @ARGV < 1){
    print STDERR "USAGE : perl $0 \$block_info \$block_length \$min_ks \$max_ks\n";
    exit;
}

my ($f,$block,$min,$max) = @ARGV;

$block//= 10;
$min //= -1;
$max //= 0.4;

open IN,'<',$f or die "$!";
my $first = readline IN;
print $first;
while(<IN>){
    chomp;
    my @l = split/,/;
    next if $l[8] < $block;
    next unless ($l[9] < $max && $l[9] > $min);
    print join",",@l;
    print "\n";
}
