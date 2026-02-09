#! perl

use warnings;
use strict;
use File::Basename;
use Cwd qw/abs_path getcwd/;

if(scalar @ARGV < 1){
    print STDERR "USAGE : perl $0 \$dir \$mafft_opt \$pal2nal_opt \$trimal_opt\n";
    exit;
}

my $h_dir = getcwd;
my $s_dir = shift;

my $mafft_opt = shift;
my $pal2nal_opt = shift;
my $trimal_opt = shift;

$mafft_opt//= "--auto --quiet";
$pal2nal_opt //= "-output fasta";
$trimal_opt //= "-gt 0.8 -w 3";

$s_dir = abs_path($s_dir);
my @ogs = `ls $s_dir`;
for my $og (@ogs){
    chomp $og;
    print "cd $s_dir/$og;";
    print "mafft $mafft_opt pep.fa > pep.align.fa;";
    print "pal2nal.pl pep.align.fa cds.fa $pal2nal_opt > cds.align.fa;";
    print "trimal -in cds.align.fa -out cds.align.fa.trim $trimal_opt;";
    print "cd $h_dir\n";
}
