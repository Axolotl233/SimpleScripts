#! perl

use Getopt::Long;
use warnings;
use strict;
use MLoadData;

my ($v,$c1,$s1,$c2,$s2,$e,$f1,$f2);
GetOptions(
    'v' => \$v,
    'c1=s' => \$c1,
    'c2=s' => \$c2,
    's1=s' => \$s1,
    's2=s' => \$s2,
    'f1=s' => \$f1,
    'f2=s' => \$f2,
    );

$c1 //= 0;
$c2 //= 0;
$s1 //= "\t";
$s2 //= "\t";

if(! $f1 || !$f2){
    print STDERR "USAGE : perl $0 --c1 [0] --c2 [0] --s1 [\\t] --s2 [\\t] --f1 \$ref --f2 \$target \n";
    exit;
}

my %r = MLoadData::load_from_file_hash_content($f1,$s1,$c1,$c1);
my @ls = MLoadData::load_from_file($f2);

for (@ls){
    next unless length $_;
    my @l = split/$s2/,$_;
    if($v){
	print $_."\n" if ! exists ($r{$l[$c2]});
    }else{
	print $_."\n" if exists ($r{$l[$c2]});
    }
}
