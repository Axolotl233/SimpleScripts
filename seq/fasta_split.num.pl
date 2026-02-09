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
    'num=s' => \$split_num
    );
$split_num //= 10000;
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
&split_fa_by_num($rr);

sub split_fa_by_num{
    my $s_obj = shift @_;
    mkdir $nn."\.$split_num\.numsplit" if ! -e $nn."\.$split_num\.numsplit";
    chdir $nn."\.$split_num\.numsplit";
    my $c = 0;
    my $d = 1;
    my $p_n = 1;
    my $p;
    my $e_n = 0;
    my $s_n = 0;
    while(my $s = $s_obj -> next_seq){
        my $id = $s -> display_id;
        my $seq = $s -> seq;
        $c += 1;
        $p .= ">$id\n$seq\n";
        if($c == ($d * $split_num)){
            $e_n = $d * $split_num;
            $s_n = $e_n - $split_num + 1;
            open O,'>',"$nn.$s_n-$e_n.fa";
            print O $p;
            close O;
            $p = "";
            $d += 1;
        }
    }
    my $last = $e_n + 1;
    open O,'>',"$nn.$last-$c.fa";
    print O $p;
    close O;
    chdir $h_dir;
}

sub load_fasta{
    my $ss = Bio::SeqIO -> new (-file => shift , -format => "fasta");
    return $ss
}

sub print_help{
    print STDERR "USAGE : perl $0 --ref \$fa [--num 10000]\n";
}
