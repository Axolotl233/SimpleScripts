#! perl

use warnings;
use strict;
use File::Basename;

if(@ARGV < 1){
    print STDERR "need dir";
    exit;
}

my $dir = shift;
my @fs = sort {$a cmp $b} grep{/blast.out/} `find $dir`;
print"sample,seq,length,SSU,ITS1,5.8S,ITS2,LSU,class\n";
for my $ft (@fs){
    chomp $ft;
    my $dd = dirname $ft;
    my $n = basename $dd;
    my $ftt = "$dd/pre_its.seq.lst";
    if((stat($ftt))[7] == 0){
	print "$n,NA,NA,NA,NA,NA,NA,NA,not_found\n";
	next;
    }
    my $f = "$dd/its.positions.txt";
    if(-e $f){
	my $size = (stat($f))[7];
	unless($size > 0){
	    print "$n,NA,NA,NA,NA,NA,NA,NA,not_found\n";
	    next;
	}
    }else{
	print STDERR "$n : is not finished";
	next;
    }
    my %jud;
    if(-e "$dd/its.problematic.txt"){
	open IN,'<',"$dd/its.problematic.txt";
	while(<IN>){
	    chomp;
	    my @l = split/\t/;
	    $jud{$l[0]} = 1;
	}
	close IN;
    }
    open IN,'<',$f;
    while(<IN>){
	chomp;
	my @l = split/\t/,$_;
	$l[1] =~ s/ bp.//;
	
	for my $i ((2,3,4,5,6)){	    
	    $l[$i] =~ s/.*: //;
	}
	print "$n,";
	print join",",@l[0..6];

	my $j = exists $jud{$l[0]}?"uncomplete":"complete";

	print ",$j";
	print "\n";
    }
    close IN;
}
   
