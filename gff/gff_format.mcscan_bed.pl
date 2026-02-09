#! perl

use warnings;
use strict;
use File::Basename;

if(scalar @ARGV < 1){
    print STDERR "\nUSAGE : perl $0 gff [mRNA|gene] [0|1|2 {0:all 1:mcscanx 2:mcscanx-python}] [extend bp]\n";
    exit;
}

my $gff = shift or die "need gff\n";
my $level = shift; #"mRNA or gene"
$level //= "mRNA";
my $jud = shift;
my $ex = shift;
$jud //= 0;
$ex //= 0;
open IN,'<',$gff;
my $m;
my $mp;
while(<IN>){
    chomp;
    next if /^#/;
    next unless length;
    my @l = split/\t/;
    next unless $l[2] eq $level;
    if($l[8] =~ /;/){
        $l[8] =~ s/.*?ID=(.*?);.*/$1/;
    }else{
        $l[8] =~ s/ID=//;
    }
    $l[3] = $l[3] - $ex;
    $l[3] = 0 if $l[3] < 0;
    $l[4] = $l[4] + $ex;
    $m .= "$l[0]\t$l[8]\t$l[3]\t$l[4]\n";
    $mp .= "$l[0]\t$l[3]\t$l[4]\t$l[8]\t$l[6]\t$l[7]\n";
}
(my $base = basename $gff) =~ s/(.*)\..*/$1/;
my $mp_o = "$base.python_mcscanx.bed";
my $m_o = "$base.mcscanx.bed";
if($jud == 0){
    open MP ,'>',$mp_o;
    print MP $mp;
    open M ,'>',$m_o;
    print M $m;
}elsif($jud == 1){
    open M ,'>',$m_o;
    print M $m;
}elsif($jud == 2){
    open MP ,'>',$mp_o;
    print MP $mp;
}
close MP;
close M;
