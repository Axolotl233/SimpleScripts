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
           'len=s' => \$split_len,
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
&split_fa_len_split($rr);

sub split_fa_len_split{
    my $s_obj = shift @_;
    mkdir $nn."\.$split_len\.lensplit" if ! -e $nn."\.$split_len\.lensplit";
    chdir $nn."\.$split_len\.lensplit";
    
    while(my $s = $s_obj -> next_seq){
        my $id = $s -> display_id;
        my $seq = $s -> seq;
        my $len = $s -> length;
        my $halfwindow = $split_len/2 ;
        my $b = $len + $split_len;
        if($split_len >= $len){
            open O,'>',"$id.fa";
            print O ">$id:0-$len\n$seq\n";
            close O;
            next;
        }
        DO:for(my $a = 0;$a < $b;$a += $split_len){
            my $jud = $a + $split_len + $halfwindow;
            unless($jud > $len){
                my $s_seq = substr($seq,$a,$split_len);
                my $end = $a + $split_len;
                my $n = $id."\:$a-$end";
                open O,'>',"$n.fa" or die "$!";
                print O ">$n\n$s_seq\n";
                close O;
            }else{
                my $l = $len - $a;
                my $s_seq = substr($seq,$a,$l);
                my $end = $len;
                my $n = $id."\:$a-$end";
                open O,'>',"$n.fa";
                print O ">$n\n$s_seq\n";
                close O;
                last DO;
            }
        }
    }
    chdir $h_dir;
}

sub load_fasta{
    my $ss = Bio::SeqIO -> new (-file => shift , -format => "fasta");
    return $ss
}

sub print_help{
    print STDERR "USAGE : perl $0 --ref \$fa [--len 1000000]\n";
}
