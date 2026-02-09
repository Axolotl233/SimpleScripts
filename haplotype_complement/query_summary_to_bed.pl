#! perl

use warnings;
use strict;
use File::Basename;
use MLoadData;
use Cwd qw(getcwd abs_path);

my $d_more = shift;
my $d_less = shift;
my $l_more = shift;
my $l_less = shift;

$l_more //= 100000;
$l_less //= 100000;

my @fs1 = &file_filter($d_more,$l_more);
my @fs2 = &file_filter($d_less,$l_less);

my %d1 = %{&load_info(\@fs1,"more")};
my %d2 = %{&load_info(\@fs2,"less")};
&print_res(\%d1);
&print_res(\%d2);

sub print_res{
    my $r = shift @_;
    my %d = %{$r};
    for my $k1(sort {$a cmp $b}keys %d){
	for my $k2 (sort {$a <=> $b} keys %{$d{$k1}}){
	    my @t = @{$d{$k1}{$k2}};
	    print "$k1\t";
	    print join"\t",@t;
	    print "\n";
	}
    }
}

sub load_info{
    my @fs = @{$_[0]};
    my $class = $_[1];
    my %h;
    for my $f (@fs){
	
	my $t = `wc -l $f`;
	my @tt = split/ /,$t;
	(my $n = basename $f) =~ s/\..*//;
	open IN,'<',$f;

	while(<IN>){
	    chomp;
	    my @l = split/\t/;
	    $h{$l[0]}{$l[1]} = [$l[1],$l[2],$class,$tt[0],$n];
	}
    }
    return \%h;
}

sub file_filter{
    my $d = shift @_;
    my $len = shift @_;
    my @fs = sort {$a cmp $b} grep{/.out.txt/} `find $d`;
    my @r;
    for my $f (@fs){
	chomp $f;
	(my $n = basename $f) =~ s/\..*//;
	my @t = split/-/,$n;
	next if $t[2]-$t[1] < $len;
	$f = abs_path($f);
	push @r, $f;
    }
    return @r;
}
