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
           'num=s' => \$split_num,
           'len=s' => \$split_len,
          );
$split_num //= 10000;
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

my @mm = split/,/,$ARGV[0];
(my $nn = basename $ref) =~ s/(.*)\..*/$1/;

for my $item (@mm){
    my $j = 0;
    if ($item eq "num"){
        my $rr = &load_fasta($ref);
        &split_fa_by_num($rr);
        $j += 1;
        undef $rr;
    }
    if ($item eq "len_split"){
        my $rr = &load_fasta($ref);
        &split_fa_len_split($rr);
        $j += 1;
        undef $rr;
    }
    if ($item eq "N"){
        my $rr = &load_fasta($ref);
	&split_fa_N($rr);
        $j += 1;
        undef $rr;
    }
    if ($item eq "1"){
	my $rr = &load_fasta($ref);
	&split_fa_1($rr);
	$j += 1;
	undef $rr;
    }
    if ($item eq "len"){
	my $rr = &load_fasta($ref);
	&split_fa_len($rr);
	$j += 1;
	undef $rr;
    }
    
    if($j == 0){
        &print_help();
        exit;
    }

}

sub split_fa_N{
    my $s_obj = shift @_;
    mkdir $nn.".Nsplit" if ! -e $nn.".Nsplit";
    chdir $nn.".Nsplit";
    while(my $s_io = $s_obj -> next_seq){
	my $id = $s_io -> display_id;
	my $seq = $s_io -> seq;
	$seq = uc($seq);
	while($seq =~ /([ACGTacgt]+)/g){
	    my $seq2 = $1;
	    my $end = pos($seq);  
	    my $start = $end - length($seq2) + 1;  
	    open O,'>',"$id\_$start-$end.fa";
	    print O ">$id\_$start-$end\n$seq2\n";
	    close O;
	}
    }
}
    	
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

sub split_fa_1{
    my $s_obj = shift @_;
    mkdir $nn."\.split" if ! -e $nn."\.split";
    chdir $nn."\.split";
    while(my $s = $s_obj -> next_seq){
        my $id = $s -> display_id;
        my $seq = $s -> seq;
	    open O ,'>', "$id.fa";
	    print O ">$id\n$seq\n";
	    close O;
    }
    chdir $h_dir;
}

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
    print STDERR "USAGE : perl $0 [num|len_split|len|N|1] --ref \$fa [--num 10000 --len 1000000]\n";
}
