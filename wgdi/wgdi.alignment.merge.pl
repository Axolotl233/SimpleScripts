#! perl

use warnings;
use strict;

if(scalar @ARGV < 2 ){
    print STDERR "USAGE : perl $0 \$alignment1 \$alignment2 ...\n";
}

my %h;
for my $f (@ARGV){
    chomp $f;
    open IN,'<',$f;
    while(<IN>){
	chomp;
	my @l = split/,/,$_,-1;
	for(my $i = 1;$i < scalar @l;$i ++){
	    push @{$h{$l[0]}},$l[$i];
	}
    }
    close IN;
}
for my $k(sort {$a cmp $b} keys %h){
    print "$k,";
    print join",",@{$h{$k}};
    print "\n";
}
