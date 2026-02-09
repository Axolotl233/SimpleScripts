#! perl

use warnings;
use strict;
use File::Basename;
use Cwd qw/abs_path getcwd/;

#muscle -align cds.fa -output cds.muscle.fa
#mafft cds.fa > cds.fa

my $dir = shift;
my $method = shift;
my $prefix = shift;
my $trim_opt = shift;

$method //= "muscle";
$prefix //= "cds";
$trim_opt //= "-gt 0.8 -w 3";

my $h_dir = getcwd();
$dir = abs_path($dir);
my @ds = `ls $dir`;
for my $d(@ds){
    chomp $d;
    my $f = "$prefix.fa";
    print "cd $dir/$d;";
    if($method eq "muscle"){
	print "muscle -align $prefix.fa -output $prefix.align.fa -threads 10;";
	print "trimal -in $prefix.align.fa -out $prefix.align.fa.trim $trim_opt;";
    }elsif($method eq "mafft"){
	print "mafft $prefix.fa > $prefix.align.fa;trimal -in $prefix.align.fa -out $prefix.align.fa.trim $trim_opt;";
    }
    print "cd $h_dir\n";
}
