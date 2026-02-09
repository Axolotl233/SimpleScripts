#! perl

use warnings;
use strict;
use Cwd qw/getcwd abs_path/;
use File::Basename;
use FindBin;

if(@ARGV < 3){
    &print_help();
    exit;
}

my $path_genome = shift;
my $path_pep = shift;
my $path_homo = shift;

my $thread_mce = shift;
$thread_mce //= 30;
my $extend_homo = shift;
$extend_homo //= 2000;

my $dir_h = getcwd();
$path_genome = abs_path($path_genome);
$path_pep = abs_path($path_pep);
$path_homo = abs_path($path_homo);

`rm -fr genome.fa; ln -s $path_genome genome.fa; samtools faidx genome.fa`;
`rm -fr pep.fa;ln -s $path_pep pep.fa`;
`perl $FindBin::Bin/z.util/phase_homo.pl $path_homo > homo.txt`;
`perl $FindBin::Bin/z.util/split_homo.pl homo.txt`;
`perl $FindBin::Bin/z.util/extend_homo.pl homo.split $thread_mce $extend_homo`;
`perl $FindBin::Bin/z.util/split_pep.pl pep.fa`;

mkdir "output" if !-e "output";

`perl $FindBin::Bin/z.util/file_prepare.pl homo.split $thread_mce > 0.genewise.run.sh`;

sub print_help{
    print STDERR "USAGE : perl $0 genome.fa pep.fa [mmseq_output|tblastn_output]\n";
}
