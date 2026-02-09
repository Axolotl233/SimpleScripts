#! perl

use warnings;
use strict;
use File::Basename;

if(scalar @ARGV != 3){
    print STDERR "USAGE : perl $0 \$og_group \$og_table \$anno \$sp_index [1 - num_col og_table] \n";
    exit;
}

my $f1 = shift;
my $f2 = shift;
my $f3 = shift;
my $nn = shift;
$nn = 1;

my %h;
my %o;
my %v;

open IN,'<',$f3;
while(<IN>){
    chomp;
    my @l = split/\t/;
    $h{$l[3]} = $l[0];
}
close IN;

open IN,'<',$f2;
readline IN;

while(<IN>){
    
    $_ =~ s/\r//;
    $_ =~ s/\n//;

    my @l = split/\t/,$_, -1 ;

    $l[-1] =~ s/, /,/g;
    my @gs = split/,/,$l[$nn];
    for my $g (@gs){
	my $chr = exists $h{$g}?$h{$g}:"NA";
	$o{$l[0]}{$chr} += 1;
	$v{$l[0]}{$g} += 1;
    }
}
close IN;

open IN,'<',$f1;
while(<IN>){
    $_ =~ s/\r//;
    $_ =~ s/\n//;
    my @l = split/\t/,$_;
    my @k1 = sort{$a cmp $b} keys %{$o{$l[0]}};
    my @k2 = sort{$a cmp $b} keys %{$v{$l[0]}};

    my $p1 = scalar @k1 == 0 ? "NA": scalar @k1 == 1? $k1[0]:"Muti";
    my $p2 = scalar @k1 == 0 ? "NA": scalar @k2 == 1? $k2[0]: join",",@k2;

    print $_."\t"."$p1\t$p2\n";
}
