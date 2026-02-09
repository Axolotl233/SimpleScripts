#! perl

use warnings;
use strict;
use MLoadData;
use File::Basename;
use Cwd qw/getcwd abs_path/;

my $h_dir = getcwd();
if(scalar @ARGV < 2){
    print STDERR "\nUSAGE : perl $0 \$block_dir \$up_depth [\$len_f] [\$trim]\n";
    exit;
}

my $dir = shift;
$dir = abs_path($dir);

my $up = shift;
my $len_f = shift;
$len_f //= "f_na";
my $trim = shift;
$trim //= 0;

my %len;
if($len_f ne "f_na"){
    %len = MLoadData::load_from_file_hash_content($len_f,"\t",0,1);
}

my @fs = grep{/block$/} `ls $dir`;
for my $f(@fs){
    chomp $f;
    (my $n = basename $f) =~ s/(.*?)\..*/$1/;
    if(keys %len > 0){
	print "perl /home/wenjie/code/paf/paf_convert.homo_block.stat.pl --block $dir/$f --depth_up $up --length_trim $trim --region 0,$len{$n} --depth_down 0 > $dir/$f.stat\n";
    }else{
	print "perl /home/wenjie/code/paf/paf_convert.homo_block.stat.pl --block $dir/$f --depth_up $up --length_trim $trim --depth_down 0 > $dir/$f.stat\n";
    }
}
