#! perl

use warnings;
use strict;
use Bio::SeqIO;

if(@ARGV < 1){
    print STDERR "USAGE : perl $0 \$fa [\$seq_list]\n";
    exit;
}

my $f = shift;
my $r = shift;

my %q;
if($r){
    open IN,'<',$r;
    while(<IN>){
        chomp;
        $q{$_} = 1;
    }
    close IN;
}
my $s_obj = Bio::SeqIO -> new(-file => $f);
while(my $s_io = $s_obj->next_seq){
    my $id = $s_io -> display_id;
    my $seq = $s_io -> seq;
    if($r){
        if(exists $q{$id}){
            my $seq2 = reverse $seq;
            $seq2 =~ tr/ATCG/TAGC/;
            $seq2 =~ tr/atcg/tagc/;
            print ">$id\n$seq2\n";
        }else{
            print ">$id\n$seq\n";
        }
    }else{
        my $seq2 = reverse $seq;
        $seq2 =~ tr/ATCG/TAGC/;
        $seq2 =~ tr/atcg/tagc/;
        print ">$id\n$seq2\n";
    }
}
    
