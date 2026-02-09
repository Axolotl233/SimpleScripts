#! perl

use warnings;
use strict;

my $f1 = shift;
my $f2 = shift;
my $f3 = shift;

my %d1;
my %d2;

open IN,'<',$f1 or die "$!";
while(<IN>){
    chomp $_;
    my @l = split/,/;
    if(scalar @l > 2){
	print "$f1:$/:$_\n";
	exit;
    }
    $l[1] = "." if (scalar @l == 1);
    pop @l if ($l[1] eq "\.");

    if(scalar @l == 2){
	$d1{$l[0]} = 1;
	$d2{$l[1]} = 1;
    }elsif(scalar @l == 1){
	$d1{$l[0]} = 1;
    }
}
close IN;

open IN,'<',$f2 or die "$!";
while(<IN>){
    chomp $_;
    my @l = split/,/;
    if(scalar @l > 2){
        print "$f2:$/:$_\n";
        exit;
    }
    $l[1] = "." if (scalar @l == 1);
    pop @l if ($l[1] eq "\.");
    
    if(scalar @l == 2){
        $d2{$l[0]} = 1;
        $d1{$l[1]} = 1;
    }elsif(scalar @l == 1){
        $d2{$l[0]} = 1;
    }
}
close IN;

open IN,'<',$f3 or die "$!";
while(<IN>){
    chomp $_;
    my @l = split/\t/;
    if((scalar @l) == 1){
	if(exists $d1{$l[0]} && !exists $d2{$l[0]}){
	    print "$l[0]\tNA\n";
	}elsif(exists $d2{$l[0]} && !exists $d1{$l[0]}){
	    print "NA\t$l[0]\n";
	}else{
	    print STDERR "ERROR1 : $_\n";
	    exit;
	}
    }elsif(scalar @l == 2){
	if(exists $d1{$l[0]} && exists $d2{$l[1]}){
            print "$l[0]\t$l[1]\n";
        }elsif(exists $d2{$l[0]} && !exists $d1{$l[0]}){
            print "$l[1]\t$l[0]\n";
	}else{
            print STDERR "ERROR2 : $_\n";
	    exit;
        }
    }else{
	next;
    }
}
