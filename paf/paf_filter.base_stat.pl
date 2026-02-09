#! perl

use warnings;
use strict;
use MLoadData;
use File::Basename;
use Getopt::Long;
use Cwd;

my $h_dir = getcwd();
my $paf = shift;
my $stat = shift;

my $query = shift;
$query //= "50000,100000,0.1";
my $target = shift;
$target //= "50000,100000,0.1";

my @q = split/,/,$query;
my @t = split/,/,$target;

if(!$paf || !$stat){
    print STDERR "\nPlease Run : \`perl paf_stat.alignment_length.pl\` to create \$stat\n\n";
    print STDERR "USAGE: perl $0 \$paf \$stat [for query:\"50000,100000,0.1\" for target:\"50000,100000,0.1\"]\n";
    exit;
}

my @stat_d = MLoadData::load_from_file($stat);
my @paf_d = MLoadData::load_from_file($paf);
my %h;
for (my $i = 0;$i < @stat_d;$i ++){
    my @l = split/\t/,$stat_d[$i];
    next if $l[5] < $t[0];
    next if $l[6] < $t[1];
    next if $l[7] < $t[2];
    next if $l[1] < $q[0];
    next if $l[2] < $q[1];
    next if $l[3] < $q[2];
    $h{"$l[0]-$l[4]"} = 1;
}

for (my $i = 0;$i < @paf_d;$i ++){
    my @l = split/\t/,$paf_d[$i];
    #print join"\t",@l;exit;
    next if ! exists $h{"$l[0]-$l[5]"};
    print $paf_d[$i]."\n";
}
