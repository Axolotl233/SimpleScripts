#! perl

use warnings;
use strict;
use File::Basename;
use Cwd qw/getcwd abs_path/;

if(scalar @ARGV < 1){
    print STDERR "usage perl $0 \$dir [\$prefix]\n";
    exit
}

my $dir = shift;
my $prefix = shift;

$prefix //= "cds";
my $h_dir = getcwd();
$dir = abs_path($dir);
my @ds = `ls $dir`;
for my $d(@ds){
    chomp $d;
    print "cd $dir/$d;";
    print "iqtree3 -s $prefix.align.fa.trim --redo -m MFP -bb 1000 -nt 4;";
    print "cd $h_dir\n";
}
