#! perl

use warnings;
use strict;
use File::Basename;
use Cwd qw/getcwd abs_path/;
use Math::Combinatorics;
use MLoadSeqInfo;

if(scalar @ARGV < 1){
    print STDERR "USAGE : perl $0 \$query_dir \$thread [40] \$option [--secondary=no -x asm20]\n";
    exit;
}

my $query_dir = shift;
my $thread = shift;
$thread //= 40;
my $option = shift;
$option //= "--secondary=no -x asm20";

my %fqs = MLoadSeqInfo::load_single_fasta($query_dir);
my @f_com = combine(2,keys %fqs);
for my $t (@f_com){
    my @pair = @{$t};
    print "minimap2 $option -t $thread $fqs{$pair[0]} $fqs{$pair[1]} > $pair[0]-$pair[1].paf\n";
}
