#! perl

use warnings;
use strict;
use File::Basename;
use MCE::Loop;
use Cwd qw/getcwd abs_path/;

my $dir = shift;
my $thread = shift;
my $bp = shift;

my @fs = grep{/.split.txt/} `find $dir`;

MCE::Loop::init {max_workers => $thread, chunk_size => 1};
mce_loop {&run($_)} @fs;

sub run{
    my $f = shift @_;
    chomp $f;
    my $f_dir = dirname $f;
    my $f_dir_n = basename dirname $f;
    (my $f_n = basename $f) =~ s/.split.txt//;

    open my $f_h,'<',$f or die "$!";
    open my $o_h,'>',"$f_dir/$f_n.block.txt" or die "$!";

    my $l_first = readline $f_h;
    chomp $l_first;
    my @l = split/\t/,$l_first;
    my $tmp_s = $l[8] - $bp;
    my $tmp_e = $l[9] + $bp;
    
    while(<$f_h>){
	chomp;
	@l = split/\t/;
	$l[8] = $l[8] - $bp;
	$l[9] = $l[9] + $bp;

	if($l[8] <= $tmp_e && $tmp_s <= $l[9]){
	    $tmp_e = $tmp_e > $l[9]? $tmp_e : $l[9];
	    $tmp_s = $tmp_s < $l[8]? $tmp_s : $l[8];
	}else{
	    print $o_h "$f_dir_n\t$tmp_s\t$tmp_e\n";
	    $tmp_s = $l[8];
	    $tmp_e = $l[9];
	}
    }
    print $o_h "$f_dir_n\t$tmp_s\t$tmp_e\n";
    close $f_h;
    close $o_h;
}
