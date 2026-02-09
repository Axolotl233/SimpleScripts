#! perl

use warnings;
use Bio::SeqIO;
use strict;

if(@ARGV < 2){
    print STDERR "\nUSAGE : perl $0 \$seq1 \$seq2 ...\n";
    print STDERR "\nused for check if the sequence between different file is the same\n";
    exit;
}

my %h;

for my $f (@ARGV){
    my $seqio_obj = Bio::SeqIO -> new(-file => $f, -format =>"fasta");
    while(my $seq_obj = $seqio_obj -> next_seq){
	my $id = $seq_obj -> display_id;
	my $seq = $seq_obj -> seq;
	if($seq =~ /\*$/){
	    $seq =~ s/\*$//;
	}
	$h{$id}{$seq} += 1;
    }
    undef $seqio_obj;
}

for my $k1 (sort {$a cmp $b} keys %h){
    my @k2 = keys %{$h{$k1}};
    print $k1."\t";
    print scalar @k2;
    if(scalar @k2 == 1){	
	print "\t$h{$k1}{$k2[0]}\n";
    }else{
	my @t;
	for my $s (@k2){
	    push @t,$h{$k1}{$s};
	}
	
	print "\t";
	print join",",@t;
	print "\n";
    }
}
