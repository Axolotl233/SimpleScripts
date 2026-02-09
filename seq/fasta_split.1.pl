#! perl

use strict;
use warnings;
use Bio::SeqIO;
use Getopt::Long;
use File::Basename;
use Cwd;

my $h_dir = getcwd();

my ($help,$ref,$split_num,$split_len);
GetOptions(
    'ref=s' => \$ref,
    'help' => \$help,
    'len=s' => \$split_len
    );
$split_len //= 0;

if($help){
    &print_help();
    exit;
}

(my $nn = basename $ref) =~ s/(.*)\..*/$1/;
my $rr = &load_fasta($ref);
&split_fa_1($rr);

sub split_fa_1{
    my $s_obj = shift @_;
    mkdir $nn."\.split" if ! -e $nn."\.split";
    chdir $nn."\.split";
    while(my $s = $s_obj -> next_seq){
        my $id = $s -> display_id;
        my $seq = $s -> seq;
	my $ll = $s -> length;
	next if $ll < $split_len; 
	open O ,'>', "$id.fa";
	print O ">$id\n$seq\n";
	close O;
    }
    chdir $h_dir;
}

sub load_fasta{
    my $ss = Bio::SeqIO -> new (-file => shift , -format => "fasta");
    return $ss
}

sub print_help{
    print STDERR "USAGE : perl $0 --ref \$fa\n";
}
