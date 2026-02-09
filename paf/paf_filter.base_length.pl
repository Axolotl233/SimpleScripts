#! perl

use warnings;
use strict;
use MLoadData;
use File::Basename;
use Getopt::Long;
use Cwd qw/getcwd abs_path/;

my $h_dir = getcwd();

my($paf,$len_q,$len_b,$len_r,$len_m,$ex_bp);
GetOptions(
    'paf=s' => \$paf,
    'min_length_query=s' => \$len_q,
    'min_length_block=s' => \$len_b,
    'min_length_ref=s' => \$len_r,
    'min_length_match=s' => \$len_m,
);

$len_q //= 5000;
$len_m //= 1000;
$len_b //= 2000;
$len_r //= 50000;
$ex_bp //= 0;

if(!$paf){
    print STDERR "\nUSAGE: perl $0 --paf paf [--min_length_query 5000 --min_length_ref 50000 --min_length_match 1000 --min_length_block 2000]\n";
    exit;
}

$paf = abs_path($paf);
open IN,'<',$paf;
while(<IN>){
    chomp;
    my @l = split/\t/;
    next if ($l[9] < $len_m);
    next if ($l[10] < $len_b);
    next if ($l[1] < $len_q);
    next if ($l[6] < $len_r);
    print $_."\n";
}
