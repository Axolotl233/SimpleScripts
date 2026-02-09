#! perl

use warnings;
use strict;
use Cwd qw/getcwd abs_path/;
use MCE::Loop;
use File::Basename;
use FindBin;

my $h_dir = getcwd();

my $dir = shift;
$dir = abs_path($dir);
my $thread = shift;
my @fs = grep{/.block.txt/} `find $dir`;

my %h = &load_fai("genome.fa.fai");

MCE::Loop::init {max_workers => $thread, chunk_size => 1};
mce_loop {&run($_)} @fs;

sub run{
    my $f = shift;
    chomp $f;
    my $f_dir = dirname $f;
    my $f_dir_n = basename dirname $f;
    (my $f_n = basename $f) =~ s/.block.txt//;
    mkdir "output/$f_dir_n/$f_n" if !-e "output/$f_dir_n/$f_n";
    chdir "output/$f_dir_n/$f_n";
    open my $f_h,'<',$f or die "$!";
    while(<$f_h>){
	chomp;
	my @l = split/\t/;
	$l[1] = 0 if $l[1] < 0;
	$l[2] = $h{$l[0]} if $l[2] > $h{$l[0]};
	mkdir "$l[1]-$l[2]" if ! -e "$l[1]-$l[2]";
	chdir "$l[1]-$l[2]";
	`samtools faidx $h_dir/genome.fa $l[0]:$l[1]-$l[2] > ref.fa`;
	`ln -s $h_dir/pep.split/$f_n.fa pep.fa`;
	chdir "$h_dir/output/$f_dir_n/$f_n";
	print "cd $h_dir/output/$f_dir_n/$f_n/$l[1]-$l[2]; genewise pep.fa ref.fa -both -pretty -pseudo -gff -cdna -trans > genewise.out;perl $FindBin::Bin/convert_genewise.pl;cd $h_dir\n";
    }
    chdir $h_dir;
#    exit;
}

sub load_fai{
    my $ref = shift @_;
    open IN,'<',$ref or die "$!";
    my %hh;
    while(<IN>){
	my @l = split/\t/;
	$hh{$l[0]} = $l[1];
	mkdir "output/$l[0]" if ! -e "output/$l[0]";
    }
    close IN;
    return %hh;
}
