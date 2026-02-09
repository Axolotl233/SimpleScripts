#! perl

#/home/wenjie/code/plot/plot_bamdst_depth_region.plot.R
use warnings;
use strict;

my $stat = shift;
my $l = shift;
my $m = shift;
my $h = shift;
my $bb = shift;

$stat //= "Median";
$l //= 50;
$m //= 100;
$h //= 150;
$bb //= 25;

my $script = "/home/wenjie/code/plot/plot_bamdst_depth_region.plot.R";
my @fs = sort{$a cmp $b} grep {/.split.file$/} `find ./`;
if(scalar @fs == 0){
    print STDERR "perl $0 \$stat \$l \$m \$h[for current directory]\n";
}
for my $f (@fs){
    chomp $f;
    print "Rscript $script --input $f --stat $stat --low_depth $l --high_depth $m --ylim $h --bin_index $bb\n";
}
