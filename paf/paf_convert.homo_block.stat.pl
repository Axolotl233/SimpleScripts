#! perl

use warnings;
use strict;
use File::Basename;
use Getopt::Long;

my($file_b,$len_t,$len_r,$d_up,$d_down,$file_tmp);
GetOptions(
    'block=s' => \$file_b,
    'length_trim=s' => \$len_t,
    'region=s' => \$len_r,
    'depth_up=s' => \$d_up,
    'depth_down=s' => \$d_down,
    'tmp_file' => \$file_tmp
    );
$len_t //=0;
$d_down //=0;
$len_r //="NA";

if(!$file_b){
    print STDERR "\nUSAGE: perl $0 --block block.file --depth_up [--length_trim 0 --region {start,end} --depth_down 0]\n";
    exit;
}

my @r;

if($len_r ne "NA"){
    @r = split/,/,$len_r;
    $r[0] = $r[0] + $len_t;
    $r[1] = $r[1] - $len_t;
    if($r[1] < 0 || $r[0] > $r[1]){
	print STDERR "wrong region para: '$len_r|$len_t', please check\n";
	exit;
    }
}else{
    my $tmp_1 = `head -n 1 $file_b`;
    my @tmp_3 = split/\t/,$tmp_1;
    $r[0] = $tmp_3[0] + $len_t;
    my $tmp_2 = `tail -n 2 $file_b|head -n 1`;
    my @tmp_4 = split/\t/,$tmp_2;
    $r[1] = $tmp_4[1] - $len_t;
    if($r[1] < 0 || $r[0] > $r[1]){
	print STDERR "wrong region based on $file_b: '$tmp_3[0],$tmp_4[1]|$len_t', please check\n";
	exit;
    }
}

open IN,'<',$file_b;
open O,'>',"$file_b.tmp";
my $last_pos = "NA";
while(<IN>){
    chomp;
    next if /^#/;
    my @l = split/\t/;
    next unless ($r[0] <= $l[1] && $l[0] <= $r[1]);
    my @cc = split/,/,$l[2];
    my $class = scalar @cc;
    $class = "low" if($class < $d_down);
    $class = "high" if($class > $d_up);
    if($last_pos eq "NA"){
	$last_pos = $l[1];
    }else{
	if($last_pos != $l[0]){
	    print O "$last_pos\t$l[0]\tunmap\n";
	}
    }
    print O "$l[0]\t$l[1]\t$class\n";
    $last_pos = $l[1];
}
close IN;
close O;

my %res;
open IN,'<',"$file_b.tmp";
(my $n = basename $file_b) =~ s/(.*?)\..*/$1/;
while(<IN>){
    chomp;
    my @l = split/\t/;
    $res{$l[2]} += $l[1] - $l[0] + 1;
}
`rm -fr $file_b.tmp` unless $file_tmp;
my $len_res = $r[1] - $r[0] + 1;
for my $k(sort {$a cmp $b} keys %res){
    my $rr = sprintf("%.4f",$res{$k}/$len_res);
    print "$n\t$k\t$res{$k}\t$rr\n";
}
