#! perl

use warnings;
use strict;
use Bio::SeqIO;

if(scalar @ARGV < 3){
    print "USAGE : perl $0 \$blast.out \$query.seq.fa \$target.seq.fa\n";
    exit;
}

my $f_blast = shift;
my $f_q = shift;
my $f_t = shift;

my %h1 = &load_seq($f_q);
my %h2 = &load_seq($f_t);
open IN,'<',$f_blast or die "$!";
while(<IN>){
    chomp;
    my @l = split/\t/;
    my @a1 = sort {$a <=> $b} ($l[6],$l[7]);
    my @a2 = sort {$a <=> $b} ($l[8],$l[9]);
    if(! exists $h1{$l[0]} || ! exists $h2{$l[1]}){
	print STDERR "no_information: $l[0]\nor\n$l[1]\n";
	exit;
    }
    my $l_1 = $h1{$l[0]};
    my $l_2 = $h2{$l[1]};

    my $ll_1 = $a1[1] - $a1[0] + 1;
    my $ll_2 = $a2[1] - $a2[0] + 1;

    my $r1 = $ll_1/$l_1;
    my $r2 = $ll_2/$l_2;

    my $r1_f = sprintf("%.4f",$r1);
    my $r2_f = sprintf("%.4f",$r2);

    my @p = ($l[0],$l[1],$l_1,$l_2,$ll_1,$ll_2,$r1_f,$r2_f);
    print join"\t",@p;
    print "\n";
}

sub load_seq{
    my $fa = shift @_;
    my %h;
    my $s_obj = Bio::SeqIO -> new(-file => $fa);
    while(my $s_io = $s_obj -> next_seq){
        my $id =$s_io -> display_id;
        my $len = $s_io -> length;
	if(exists $h{$id}){
	    print STDERR "duplicate seq : $fa : $id\n";
	    exit;
	}else{
	    $h{$id} = $len;
	}
    }
    return %h;
}

    
