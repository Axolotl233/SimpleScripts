#! perl

use strict;
use warnings;
use File::Basename;

my $f = shift;
my $extend = shift;
$extend //= 0;
my %gff;
my %d;

open F,'<',$f or die "need gff file\n";
while (<F>) {
    next if /^#/;
    chomp;
    my @l=split(/\s+/,$_);
    if ($l[2] eq 'mRNA'){
	$l[8]=~/ID=([^;]+);.*?;?Parent=([^;]+)/;
	my ($trans,$gene)=($1,$2);
	$gff{gene}{$l[0]}{$gene}{$trans}=$l[4]-$l[3]+1;
	$d{$l[0]}{$gene}=$l[6];
    }elsif ($l[2] eq 'CDS') {
        $l[8]=~/ID=([^;]+);.*?Parent=([^;]+)/;
        my ($CDS,$trans)=($1,$2);
        $gff{CDS}{$trans}{$l[3]}=$l[4];
    }
}
close F;

for my $chr (sort keys %{$gff{gene}}){
    for my $gene (sort keys %{$gff{gene}{$chr}}){
	my $ord = $d{$chr}{$gene};
	my @trans=sort{$gff{gene}{$chr}{$gene}{$b} <=> $gff{gene}{$chr}{$gene}{$a}} keys %{$gff{gene}{$chr}{$gene}};
	for my $tt(@trans){
	    #print "$chr\t$gene\t$trans\t";
	    my @pos;
	    my $c1 = 0;
	    my @ss = sort{$a<=>$b} keys %{$gff{CDS}{$tt}};
	    my $max = $gff{CDS}{$tt}{$ss[-1]};
	    my $min = $ss[0];
	    for my $s (@ss){
		my $e = $gff{CDS}{$tt}{$s};
		$c1 = $c1 + $e - $s + 1;
		push @pos,"$s-$e";
	    }
	    my $c2 = $max - $min + 1;
	    $max = $max + $extend;
	    $min = $min - $extend;
	    $min = $min < 1? 1:$min;
	    
	    my $c3 = $c2 - $c1;
	    my $d = scalar @pos;
	    my @p = ($chr,$gene,$tt,$min,$max,$ord,$c2,$c1,$c3,$d,(join";",@pos));
	    print join"\t",@p;
	    print "\n";
	}
    }
}

