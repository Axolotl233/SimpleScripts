#! perl

use warnings;
use strict;
use MLoadData;

if(scalar @ARGV != 2){
    print STDERR "USAGE : perl $0 \$agp \$seq_lst\n";
    exit;
}
my $f1 = shift;
my $f2 = shift;

my @ls = MLoadData::load_from_file($f1);
my %lst = MLoadData::load_from_file_hash_content($f2,"\t",0,1);

for my $t (@ls){
    my @l = split/\t/,$t;
    if($l[4] eq "W"){
	if($l[5] =~ /_d\d+/){
	    (my $tn = $l[5]) =~ s/_d\d+//;
	    if(exists $lst{$tn}){
		print $t."\n";
	    }else{
		$l[5] = $tn;
		print join"\t",@l;
		print "\n";
	    }
	}else{
	    print $t."\n";
	}
    }else{
	print $t."\n";
    }
}
