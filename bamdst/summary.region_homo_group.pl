#! perl

use warnings;
use strict;

if(scalar @ARGV < 1){
    print STDERR "USAGE : perl $0 \$group_file\n\n";
    print STDERR "        group_file should have two columns seprated by tab, [Chr_name,homo_group]\n";
    print STDERR "        files could be created by 'msplitf' or could be found in a dir named 'region.tsv.gz.split' and formated as 'xxx.split.file'\n";
    exit;
}

my %h;
open IN,'<',shift;
while(<IN>){
    chomp;
    my @l = split/\t/;
    push @{$h{$l[1]}}, $l[0];
}
close IN;

mkdir "region.tsv.group" if !-e "region.tsv.group";
for my $k(keys %h){
    my @tt = @{$h{$k}};
    open O,'>',"region.tsv.group/$k.region.tsv";
    for my $f (@tt){
	open I,'<',"region.tsv.gz.split/$f.split.file" or die "$!";
	while(<I>){
	    print O $_;
	}
	close I;
    }
    close O;
}
