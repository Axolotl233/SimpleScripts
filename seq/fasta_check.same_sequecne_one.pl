#! perl

use warnings;
use Bio::SeqIO;
use strict;

if(@ARGV < 1){
    print STDERR "\nUSAGE : perl $0 \$seq1 \$seq2 ...\n";
    print STDERR "\nused for check if the sequence have the duplication in the separately file\n";
    exit;
}

for my $f (@ARGV){
    my %h;
    my $seqio_obj = Bio::SeqIO -> new(-file => $f, -format =>"fasta");
    while(my $seq_obj = $seqio_obj -> next_seq){
	my $id = $seq_obj -> display_id;
	my $seq = $seq_obj -> seq;
	if($seq =~ /\*$/){
	    $seq =~ s/\*$//;
	}
	$h{$id}{$seq} += 1;
	
    }
    for my $k1 (sort {$a cmp $b} keys %h){
	my @k2 = keys %{$h{$k1}};
	if(scalar @k2 == 1){
	    if($h{$k1}{$k2[0]} > 1){
		print "$f\t$k1\tdup_seq\n";
	    }
	}else{
	    print "$f\t$k1\tdiff_seq\n";
	}
    }
    undef $seqio_obj;
}
