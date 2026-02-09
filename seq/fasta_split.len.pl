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
$split_len //= 1000000;
if($help){
    &print_help();
    exit;
}

if(@ARGV != 0){
    if(! defined $ref){
        print STDERR "need a fasta file \n\n";
	    &print_help();
        exit;
    }
}else{
    &print_help();
    exit;
}

(my $nn = basename $ref) =~ s/(.*)\..*/$1/;
my $rr = &load_fasta($ref);
&split_fa_len($rr);

sub split_fa_len{
    my $s_obj = shift @_;
    mkdir $nn."\.$split_len\.len" if ! -e $nn."\.$split_len\.len";
    chdir $nn."\.$split_len\.len";
    my $p = undef;
    my $t_len = 0;
    my $d = 1;
    while(my $s = $s_obj -> next_seq){
        my $id = $s -> display_id;
        my $seq = $s -> seq;
        my $len = $s -> length;
        $t_len = $t_len + $len;
        if($t_len >= $split_len){
            open O,'>',"$t_len.$d.fa";
            print O $p;
            close O;
            $d += 1;
            $p = undef;
        }else{
            $p = $p.">$id\n$seq\n";
        }
    }
    open O,'>',"$t_len.$d.fa";
    print O $p;
    close O;
}

sub load_fasta{
    my $ss = Bio::SeqIO -> new (-file => shift , -format => "fasta");
    return $ss
}

sub print_help{
    print STDERR "USAGE : perl $0 --ref \$fa [--len 1000000]\n";
}
