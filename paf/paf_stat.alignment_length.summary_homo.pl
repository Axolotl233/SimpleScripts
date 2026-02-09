#! perl

use warnings;
use strict;
use MLoadData;
use List::Util qw/sum/;
use File::Basename;

if(scalar @ARGV < 2){
    print STDERR "USAGE: perl $0 \$stat \$chr_info \[target|query]\n";
    exit;
}
my $f1 = shift;
my $n = basename $f1;
my $f2 = shift;
my $class = shift;
$class //= "target";
my @c;

if($class eq "target"){
    @c = (4,0,3);
}elsif($class eq "query"){
    @c = (0,4,7);
}else{
    print STDERR "USAGE: perl $0 \$stat \$chr_info \[target|query]\n";
    exit;
}

my @dd = MLoadData::load_from_file($f1);
my %info = MLoadData::load_from_file_hash_content($f2,"\t",0,1);

my %h;
open O1,'>',"$n.summary";
open O2,'>',"$n.best";
for my $tmp (@dd){
    my @l = split/\t/,$tmp;
    push @{$h{$l[$c[1]]}{$info{$l[$c[0]]}}},$l[$c[2]];
}

for my $k1 (sort {$a cmp $b} keys %h){
    my $best = "NA";
    my $t_best = 0;
    for my $k2 (sort {$a cmp $b} keys %{$h{$k1}}){
	my @t = @{$h{$k1}{$k2}};
	my $s = sum(@t);
	print O1 "$k1\t$k2\t$s\n";
	if($best eq "NA"){
	    $t_best = $s;
	    $best = $k2;
	}else{
	    if($s > $t_best){
		$best = $k2;
		$t_best = $s;
	    }elsif($s == $t_best){
		$best = $best.",$k2";
	    }
	}
    }
    print O2 "$k1\t$best\t$t_best\n";
}
