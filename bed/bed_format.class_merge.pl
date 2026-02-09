#! perl

use warnings;
use strict;
use List::Util qw/uniq/;

if(scalar @ARGV == 0){
    &print_help();
    exit;
}

my $f = shift;
my %d;
open IN,'<',$f or die "$!";
my $first = readline IN;
chomp $first;
my @l = split/\t/,$first;
my $chr = $l[0];
my @p = [$l[1],$l[2],$l[3]];
#print ${$p[-1]}[0];exit;

while(<IN>){
    chomp;
    @l = split/\t/;
    if($l[0] ne $chr){
	print STDERR "different chromosome name: $_\n";
	exit;
    }
    if(${$p[-1]}[1] >= $l[1] && $l[2] >= ${$p[-1]}[0]){
	push @p, [$l[1],$l[2],$l[3]];
    }else{
	my @pp = &merge_block(\@p);
	@p = [$l[1],$l[2],$l[3]];
	print "##\n";
	print join"\n",@{$_} for @pp;
	print "\n";
    }
}

my @pp = &merge_block(\@p);
print "##\n";
print join"\n",@{$_} for @pp;
print "\n";
    
sub merge_block{
    my $ref1 = shift @_;
    my @arr1 = @{$ref1};
    my %h_bc;
    my @res;
    my ($global_min, $global_max) = (undef, undef);    
    for my $ref2 (@arr1){
	my @arr2 = @{$ref2};
	$global_min = defined $global_min ? ($arr2[0] < $global_min? $arr2[0]:$global_min):$arr2[0];
        $global_max = defined $global_max ? ($arr2[1] > $global_max? $arr2[1]:$global_max):$arr2[1];
	for (my $i = $arr2[0];$i <= $arr2[1];$i++){
	    push @{$h_bc{$i}},$arr2[2];
	}
    }
    my %hh;

    for(my $kk = $global_min; $kk <= $global_max; $kk += 1){
	my @t = sort {$a cmp $b} @{$h_bc{$kk}};
	@t = uniq @t;
	$h_bc{$kk} = \@t;
    }
    
    my @t_first = sort {$a cmp $b} @{$h_bc{$global_min}};
    my $r_first = join",",@t_first;
    my $pos_first = $global_min;
    for(my $kk = $global_min + 1; $kk <= $global_max; $kk += 1){
	my @t = sort {$a cmp $b} @{$h_bc{$kk}};
	my $r = join",", @t;
	if($r ne $r_first){
            push @res,"$pos_first\t$kk\t$r_first";
            $r_first = $r;
            $pos_first = $kk;
	}
    }
    push @res,"$pos_first\t$global_max\t$r_first";
    return \@res;
}

sub print_help{
    print STDERR "USAGE : perl $0 \$chr.split.file\n\n";
    print STDERR "cat *bed | cat blast.output.bed mmseq.output.bed|sort -k1,1 -k2,2n -k3,3n -k4,4 > merge.bed\n";
    print STDERR "perl /home/wenjie/code/file/split_file_by_col.pl merge.bed\n";
}
