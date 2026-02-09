#! perl

use warnings;
use strict;

if(@ARGV < 2){
    print STDERR "USAGE : perl $0 Orthogroups.tsv \$sp1 \$sp2 ... \$spn\n";
    print STDERR "        use regular expression to find matching, careful\n";
    exit;
}

my $f1 = shift;
open IN,'<',$f1 or die "$!";
my $head = readline IN;
chomp $head;
my @heads = split/\t/,$head;

my %n;
$n{0} = 1;
for(my $i = 1;$i < @heads;$i ++){
    for my $s (@ARGV){
	$n{$i} = 1 if $heads[$i] =~ /$s/;
    }
}

my @t = sort {$a <=> $b} keys %n;
print join"\t",@heads[@t];
print "\n";

while(<IN>){
    chomp;
    my @l = split/\t/;
    my @p;
    my %j;
    for(my $i = 1;$i < @l;$i ++){
	if (exists $n{$i}){
	    push @p, $l[$i] ;
	}
    }
    for my $t (@p){
	$j{$t} = 1 if $t ne "";
    }
    if(scalar keys %j > 0){
	print "$l[0]\t";
	print join"\t",@p;
	print "\n";
    }
}
close IN;
