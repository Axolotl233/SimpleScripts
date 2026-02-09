#! perl

use warnings;
use strict;
use Getopt::Long;
use Cwd qw(abs_path getcwd);
use File::Basename;
use MLoadData;
use MLoadSeqInfo;

my($ref,@in_dir,$out_dir,$option,$threads,$cover,$black_lst);
GetOptions(
    'genome=s' => \$ref,
    'in=s' => \@in_dir,
    'out=s' => \$out_dir,
    'option=s' => \$option,
    'threads=s' => \$threads,
    'black=s' => \$black_lst,
    'cover' => \$cover,
          );
if ((! $ref) || (scalar @in_dir == 0)){
    &print_help;
    exit;
}

$out_dir //= "./";
$threads //= 40;
$option //= "-M";
my %b;
%b = MLoadData::load_from_file_hash($black_lst) if ($black_lst);

my %file;
for my $dir (@in_dir){
    my %t_file;
    %t_file = MLoadSeqInfo::load_paired_fastq($dir);
    %file = (%t_file, %file);
}

if(scalar keys %file == 0){
    &print_help;
    exit;
}
mkdir $out_dir if !-e $out_dir;

foreach my $name (sort keys %file){
    next if exists $b{$name};
    my @fq = @{$file{$name}};
    my $threads2 = int($threads/4);
    $threads2 = 1 if $threads2 < 1;
    my $command1 = "bwa-mem2 mem -R '\@RG\\tID:$name\\tPL:illumina\\tPU:illumina\\tLB:$name\\tSM:$name' -t $threads $option $ref $fq[0] $fq[1]";
    my $command2 = "| samtools view -hF 256 - |samtools sort -O bam -@ $threads2 -T $name\.tmp -o $name\.sort.bam";
    if($cover){
	print $command1;
	print $command2;
	print "\n";
    }else{
	next if -e "$out_dir/$name.sort.bam";
	print $command1;
        print $command2;
        print "\n";
    }
}
sub print_help{
   print STDERR<<USAGE;

   Usage: perl $0 --in <reads dir> --genome <path2genome>
      --in       dir contain reads file[format : xxxx_1.fq.gz xxxx_2.fq.gz]
      --genome   reference genome
    Options:
      --out      defalut [./]
      --threads  defalut [30]
      --cover    rewrite bam file if it exist alread
      --black    black list of sample

USAGE
}
