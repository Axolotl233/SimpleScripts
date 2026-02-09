#! perl

use warnings;
use strict;
use Cwd qw/getcwd abs_path/;

if(scalar @ARGV < 2){
    print STDERR "USAGE : perl $0 \$custom.gff \$prefix [\$dir=gene_prediction]\n";
    exit;
}

my $h_dir = getcwd();
my $gff = shift;
my $prefix = shift;
my $dir = shift;
$dir //= "gene_prediction";
$dir = abs_path($dir);

my %h;
open IN,'<',$gff or die "$!";
while(<IN>){
    chomp;
    next if /^$/;
    next if /^#/;
    my @l = split/\t/;
    push @{$h{$l[0]}}, $_;
}

`mkdir -p $dir/1.abinitio/$prefix/results`;
chdir "$dir/1.abinitio/$prefix/results";
for my $k (keys %h){
    open O,'>',"$k.gff";
    print O $_."\n" for @{$h{$k}};
    close O;
}
chdir $h_dir;
