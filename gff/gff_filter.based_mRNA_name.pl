#! perl

use warnings;
use strict;
use MLoadData;

if(scalar @ARGV < 2){
    print STDERR "\nThis script just can used for gff only contain longest mRNA, and just contain gene, mRNA, exon, CDS\n";
    print STDERR "\nUSAGE : perl $0 \$gff \$mrna_lst [\$col \$sep]\n";
    exit;
}

my $col;
my $sep;
if(scalar @ARGV == 2){
    $col = 0;
    $sep = "\t";
}else{
    $col = $ARGV[2];
    $sep = $ARGV[3];
}

my @gff = MLoadData::load_from_file($ARGV[0]);
my %f_mrna = MLoadData::load_from_file_hash_content($ARGV[1],$sep,$col,$col);
my %count;
my @pp;

D:for(my $i = 0;$i < scalar @gff;$i ++){
    my @l = split/\t/,$gff[$i];
    if($l[2] eq "gene"){
	if($i == 0){
	    next D;
	}else{
	    next D if scalar @pp == 0;
	    for(my $j = $pp[0];$j < $i;$j ++){
		$count{$j} = 1;
	    }
	    @pp = ();
	}
    }elsif($l[2] eq "mRNA"){
	(my $id = $l[8]) =~ s/.*ID=(.*?);.*/$1/;
	if(exists $f_mrna{$id}){
	    @pp = $i-1;
	}
    }else{
	next D;
    }
}

for(my $i = 0;$i < scalar @gff;$i ++){
    print $gff[$i]."\n" unless exists $count{$i};
}
