#! perl

use warnings;
use strict;
use File::Basename;
use Cwd qw/getcwd abs_path/;

if(scalar @ARGV < 3){
    print STDERR "USAGE : perl $0 \$ref \$ref_rep_k15 \$query \$thread [40] \$option [--secondary=no --sam-hit-only --sv-off -ax map-pb]\n";
    exit;
}

my $ref = shift;
my $ref_rep = shift;
my $query_dir = shift;
my $thread = shift;
$thread //= 40;
my $option = shift;
$option //= "--secondary=no --sam-hit-only --sv-off -ax map-pb";

my $q_dir = abs_path($query_dir);
my @fs = grep{/(fastq|fasta)(\.gz)?$/} `ls $q_dir`;

for my $f(@fs){
    chomp $f;
    (my $n = $f) =~ s/\..*//;
    print "winnowmap -W $ref_rep $option -t $thread $ref $q_dir/$f | samtools sort -O bam -@ 60 -T $n.tmp -o $n.sort.bam\n";
}

