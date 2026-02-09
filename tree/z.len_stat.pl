#! perl

use warnings;
use strict;
use File::Basename;
use Cwd qw/getcwd abs_path/;
use Bio::SeqIO;

my $dir = shift;
my $prefix = shift;

$prefix //= "cds";
my $h_dir = getcwd();
$dir = abs_path($dir);
my @ds = `ls $dir`;

my %h;
my $head = "NA";
for my $d(@ds){
    chomp $d;
    my $f = "$d/cds.fa";
    my $s_obj = Bio::SeqIO -> new (-file => $f , -format => "fasta");
    my %s;
    while(my $s_io = $s_obj -> next_seq){
        my $id = $s_io -> display_id;
        my $len = $s_io -> length;
        $s{$id} = $len;
	$h{$id} = 1;
    }
    if($head eq "NA"){
	print "OG";
	print "\t$_" for sort {$a cmp $b} keys %h;
	print "\n";
	$head = "y";
    }
    print "$d";
    for my $sp(sort {$a cmp $b} keys %h){
	print "\t$s{$sp}";
    }
    print "\n";
}
