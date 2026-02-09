#! perl

use warnings;
use strict;
use MLoadData;
use File::Basename;
use Cwd;

my @fs = ("/home/wenjie/project/Bpho6/01.assembly/hifiasm_hic/D20a5r5/1.hap1_2_merge/0.hap1.long.20k/chromosomes.depth_distribution.txt","/home/wenjie/project/Bpho6/01.assembly/hifiasm_hic/D20a5r5/1.hap1_2_merge/0.hap2.long.20k/chromosomes.depth_distribution.txt");

my %r = &load_data(@fs);
my $dir = getcwd();
my @cs = split/\-/,(basename $dir);
print "$r{$_}\n" for @cs;

sub load_data{
    my %h;
    for my $f (@_){
	open IN,'<',$f;
	readline IN;
	while(<IN>){
	    chomp;
	    my @l = split/\t/;
	    $h{$l[0]} = $_;
	}
	close IN;
    }
    return %h;
}
