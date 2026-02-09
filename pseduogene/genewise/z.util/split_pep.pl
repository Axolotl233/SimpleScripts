#! perl

use warnings;
use strict;
use Bio::SeqIO;
use File::Basename;
use Cwd;

my $h_dir = getcwd();
my $f = shift;
my $s_obj = Bio::SeqIO -> new (-file => $f , -format => "fasta");

mkdir "pep.split" if ! -e "pep.split";
chdir "pep.split";

while(my $s = $s_obj -> next_seq){
    my $id = $s -> display_id;
    my $seq = $s -> seq;
    open O ,'>', "$id.fa";
    print O ">$id\n$seq\n";
    close O;
}

chdir $h_dir;
