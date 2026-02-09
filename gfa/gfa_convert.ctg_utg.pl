#! perl

use warnings;
use strict;
use File::Basename;

if(@ARGV != 2){
    print STDERR "USAGE : perl $0 \$utg_gfa \$ctg_gfa\n";
    exit;
}

my $f1 = shift;
my $f2 = shift;
(my $n = basename $f1) =~ s/\..*//;

my %h;

open IN, '<', "$f1";
while(<IN>){
    chomp;
    my @l = split/\t/,$_;
    if($l[0] eq "S"){
	next;
    }elsif ($l[0] eq "A"){
	if(exists $h{$l[4]}) {
	    print STDERR "dup reads name in $f1 : $l[4]\n";
	    exit;
	}else{
	    $h{$l[4]} = $l[1];
	}
    }
}
close IN;

my %us;

open IN,'<', "$f2";
my $l_tmp = readline IN;
my @l_tmps = split/\t/,$l_tmp;
my $seq_nc = $l_tmps[1];

my @rs;
my %rr;
my @p;

open O1,'>',"$n.ctg2utg.table.txt";
while(<IN>){
    chomp;
    my @l = split/\t/,$_;
    if($l[0] eq "S"){

	D:for my $r (@rs){
	    if(!exists $h{$r}){
		print "$r can not be found in $f1\n";
		#exit;
		next D;
	    }
	    my $u = $h{$r};
	    $rr{$u} += 1;
	    push @{$us{$u}}, $seq_nc;
	}
	my @tt_k;
	my @tt_v;

	for my $k (sort {$a cmp $b} keys %rr){
	    push @tt_k, $k;
	    push @tt_v, $rr{$k};
	}
	@p = ($seq_nc,scalar keys %rr,(join",",@tt_k));
	print O1 join"\t",@p;
	print O1 "\n";
	
	@p = ();
	%rr = ();
	@rs = ();
	$seq_nc = $l[1];
    }elsif ($l[0] eq "A"){
	push @rs, $l[4];
    }
}

T:for my $r (@rs){
    if(!exists $h{$r}){
	print "$r can not be found in $f1\n";
	#exit;
	next T;
    }
    my $u = $h{$r};
    $rr{$u} += 1;
    push @{$us{$u}}, $seq_nc;
}
my @tt_k;
my @tt_v;

for my $k (sort {$a cmp $b} keys %rr){
    push @tt_k, $k;
    push @tt_v, $rr{$k};
}
@p = ($seq_nc,scalar keys %rr,(join",",@tt_k));
print O1 join"\t",@p;
print O1 "\n";

open O2,'>',"$n.utg2ctg.table.txt";
for my $k (sort {$a cmp $b} keys %us){
    my @arr = @{$us{$k}};
    my %un;
    for my $t (@arr){
	$un{$t} = 1;
    }
    print O2 "$k\t";
    print O2 join",",keys %un;
    print O2 "\n";
}
close O2;
