#! perl

use warnings;
use strict;
use File::Basename;
use Cwd qw/getcwd abs_path/;

if(scalar @ARGV < 2){
    print STDERR "USAGE : perl $0 \$ref \$query_dir \$out_format [bam|paf] \$thread [40] \$option [--secondary=no -x map-hifi]\n";
    exit;
}

my $ref = shift;
my $query_dir = shift;

my $out_format = shift;
$out_format //= "bam";
my $thread = shift;
$thread //= 40;
my $option = shift;
$option //= "--secondary=no -x map-hifi";

my $q_dir = abs_path($query_dir);
my @fs = grep{/(fastq|fasta)(\.gz)?$/} `ls $q_dir`;

for my $f(@fs){
    chomp $f;
    my $t2 = int($thread/4);
    (my $n = $f) =~ s/\..*//;
    if($out_format eq "bam"){
	print "minimap2 $option -a -t $thread $ref $q_dir/$f | samtools sort -O bam -@ $t2 -T $n.tmp -o $n.sort.bam\n";
    }elsif($out_format eq "paf"){
	print "minimap2 $option -a -t $thread $ref $q_dir/$f > $n.paf";
    }
}

