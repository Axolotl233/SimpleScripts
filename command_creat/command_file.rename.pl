#! perl

use warnings;
use strict;

my $old = shift;
my $new = shift;
die "need regx" if ! $old;
$new //= "";

my @fs = sort {$a cmp $b} `ls -a ./`;
for my $f (@fs){
    chomp $f;
    if($f =~ /$old/){
	(my $n_f = $f) =~ s/$old/$new/;
	print "mv $f $n_f \n";
    }
}

