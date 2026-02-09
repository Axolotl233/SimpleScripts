#! perl

use warnings;
use strict;
use MLoadData;
use File::Basename;

if(scalar @ARGV < 2){
    print STDERR "USAGE: perl $0 \$stat \$chr_info \[target|query]\n";
    exit;
}

my $f1 = shift;
my $f2 = shift;
my $class = shift;
$class //= "target";
my $c;

if($class eq "target"){
    $c = 4;
}elsif($class eq "query"){
    $c = 0;
}else{
    print STDERR "USAGE: perl $0 \$stat \$chr_info \[target|query]\n";
    exit;
}

my @dd = MLoadData::load_from_file($f1);
my %info = MLoadData::load_from_file_hash($f2);

my %h;
for my $tmp (@dd){
    my @l = split/\t/,$tmp;
    if(exists $info{$l[$c]}){
	print $tmp."\n";
    }
}
