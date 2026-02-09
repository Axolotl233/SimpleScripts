#! perl

use warnings;
use strict;
use MLoadData;
use List::Util qw /uniq/;

my $f1 = shift;
my $f2 = shift;

if (! $f1 || ! $f2){
    print "need files\n";
    exit;
}

my %h;

my @f1_c = MLoadData::load_from_file($f1);
for my $tmp_c (@f1_c){
    my @l = split/\t/,$tmp_c;
    $h{$l[0]} = $tmp_c;
}

my @f2_c = MLoadData::load_from_file($f2);
my %hh;
for my $tmp_c (@f2_c){
    my @l = split/\t/,$tmp_c;
    my @ll = split/,/,$l[3];
    @ll = uniq(@ll);
    my $p = join",",@ll;
    next if exists $hh{$p};
    $hh{$p} = 1;
    
    for my $t (sort {$a cmp $b} @ll){
	print $h{$t};
	print "\n";
    }
    print "#\n";
}