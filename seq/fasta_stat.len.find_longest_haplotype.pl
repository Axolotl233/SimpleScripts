#! perl

use warnings;
use strict;
use MFileIO;

if(@ARGV != 1){
    print STDERR "\nUSAGE : perl $0 \$seq_len\n";
    exit;
}

my %h;

my $fh = MFileIO::handle($ARGV[0]);
while(<$fh>){
    chomp;
    my @l = split/\t/;
    (my $n = $l[0]) =~ s/(.*)_?\w\w/$1/;
    $h{$n}{$l[1]} = $l[0];
}
D:for my $k(sort {$a cmp $b }keys %h){
    for my $len (sort {$b <=> $a} keys %{$h{$k}}){
	print "$h{$k}{$len}\n";
	next D;
    }
}
