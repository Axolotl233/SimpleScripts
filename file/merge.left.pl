#! perl

use Getopt::Long;
use warnings;
use strict;
use MLoadData;

my ($c1,$s1,$c2,$s2,$e,$f1,$f2);
GetOptions(
    'c1=s' => \$c1,
    'c2=s' => \$c2,
    's1=s' => \$s1,
    's2=s' => \$s2,
    'f1=s' => \$f1,
    'f2=s' => \$f2
    );

$c1 //= 0;
$c2 //= 0;
$s1 //= "\t";
$s2 //= "\t";

if(! $f1 || !$f2){
    print STDERR "USAGE : perl $0 --c1 [0] --c2 [0] --s1 [\\t] --s2 [\\t] --f1 \$ref --f2 \$target \n";
    exit;
}
my %r;
my @l2 = MLoadData::load_from_file($f2);
my $n = 0;
for (@l2){
    next unless length $_;
    my @l = split/$s2/,$_;
    my @l_n = @l;
    splice @l_n, $c2, 1 ;
    $r{$l[$c2]} = join"$s2",@l_n;
    $n = scalar @l_n > $n? scalar @l_n:$n
}
my @l1 = MLoadData::load_from_file($f1);
for (@l1){
    next unless length $_;
    my @l = split/$s1/,$_;
    if(exists $r{$l[$c1]}){
	print "$_";
	print "$s1";
	$r{$l[$c1]} =~ s/$s2/$s1/g;
	print $r{$l[$c1]};
	print "\n";
    }else{
	print "$_";
	for(my $i = 0;$i < $n;$i += 1){
	    print "\tNA";
	}
	print "\n";
    }
}
