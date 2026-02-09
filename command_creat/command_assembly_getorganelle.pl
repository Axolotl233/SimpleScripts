#! perl

use warnings;
use strict;
use Cwd qw(abs_path getcwd);
use MLoadData;
use MLoadSeqInfo;

#get_organelle_from_reads.py -1 Arabidopsis_simulated.1.fq.gz -2 Arabidopsis_simulated.2.fq.gz -t 1 -o Arabidopsis_simulated.plastome -F embplant_pt -R 10
if(scalar @ARGV < 1){
    print STDERR "USAGE : perl $0 \$in_dir \$out_dir \$threads \$options\n";
    exit;
}

my $in_dir = shift;
$in_dir = abs_path($in_dir);
my $out_dir = shift;
$out_dir //= "./";
my $threads = shift;
$threads //= 20;
my $option = shift;
$option //= "";

my %seqs = MLoadSeqInfo::load_paired_fastq($in_dir);
foreach my $name (sort keys %seqs){
    my @fq = @{$seqs{$name}};
    print "get_organelle_from_reads.py -1 $fq[0] -2 $fq[1] -t $threads -o $out_dir/$name -F embplant_pt\n";
}
