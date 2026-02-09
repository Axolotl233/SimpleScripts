#! perl

use strict;
use warnings;

my $diamond="diamond";
my $db=shift or die "perl $0 database query max_target_seqs\n";
my $query=shift or die "perl $0 database query max_target_seqs\n";
my $maxtarget=shift or die "perl $0 database query max_target_seqs\n";
my $threads=shift;

$threads//=20;

`mkdir tmp` if (! -e "./tmp");

print "$diamond makedb --in $db -d database\n";
print "$diamond blastp --db database --query $query --out blastp.out --outfmt 6 -p $threads --sensitive --max-target-seqs $maxtarget --evalue 1e-5 --block-size 20.0 --tmpdir ./tmp --index-chunks 1\n";
