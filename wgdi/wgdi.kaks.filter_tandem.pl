#! perl

use warnings;
use strict;

if(@ARGV < 2){
    print STDERR "USAGE : perl $0 \$kaks \$wgdi.gff \$range [10] \n";
    exit;
}

my $f1 = shift;
my $f2 = shift;
my $r = shift;
$r //= 10;

my %h;

open IN,'<',$f2;
while(<IN>){
    chomp;
    my @l = split/\t/;
    $h{$l[0]}{$l[2]}{$l[3]} = $l[1];
}
close IN;

my %r1;
my %r2;
for my $k1 (sort {$a cmp $b} keys %h){
    my $n = 0;
    for my $k2(sort {$a <=> $b} keys %{$h{$k1}}){
	for my $k3(sort {$a <=> $b} keys %{$h{$k1}{$k2}}){
	    my $g = $h{$k1}{$k2}{$k3};
	    $r1{$g} = [$k1,$n];
	    $r2{$k1}{$n} = $g;
	    $n += 1;
	}
    }
}

open IN,'<',$f1;
my $l1 = readline IN;
print $l1;
D:while(<IN>){
    chomp;
    my @l = split/\t/;
    my @info = @{$r1{$l[0]}};
    my $i1 = $info[1] - $r;
    my $i2 = $info[1] + $r;
    for (my $i = $i1;$i < $i2;$i++){
	if(exists $r2{$info[0]}{$i}){
	    if ($r2{$info[0]}{$i} eq $l[1]){
		next D;
	    }
	}
    }
    print join"\t",@l;
    print "\n";
}
close IN;
