#! perl

use warnings;
use strict;
use Getopt::Long;
use File::Basename;
use Bio::SeqIO;
use MLoadData;

my ($out_blast, $max_target, $ident, $cov, $seq, $mode);
GetOptions(
    'blast=s' => \$out_blast,
    'max_target=s' => \$max_target,
    'ident=s' => \$ident,
    'cov=s' => \$cov,
    'seq=s' => \$seq,
    'mode=s' => \$mode
          );

$max_target //= 1;
$ident //= 0.4;
$cov //= 0.4;
$seq //= "NA";
$mode //= "query";

if (! $out_blast){
    &print_help();
    exit;
}
my %len;
my %blast = %{&blast_load($out_blast)};
my %blast_f;
if($seq ne "NA"){
    %len = &load_fasta($seq);
    &blast_filter(\%blast,"seq");
}else{
    &blast_filter(\%blast,"no");
}


sub blast_load{
    my $f = shift @_;
    my %h;
    open IN,'<', $f or die "$!";
    while(<IN>){
        my @l = split/\t/;
        chomp $l[-1];
	if($mode eq "query"){
	    push @{$h{$l[0]}} , [$l[0],$l[2],($l[7]-$l[6]),$l[-1],$_];
	}elsif($mode eq "target"){
	    push @{$h{$l[1]}} , [$l[0],$l[2],($l[7]-$l[6]),$l[-1],$_];
	}
    }
    close IN;
    return \%h
}

sub blast_filter{
    my $ref = shift @_;
    my $j = shift @_;
    my %h = %{$ref};
    my %p;
    for my $k (keys %h){
        my @arr = @{$h{$k}};
        my @arr_n;
        for my $t_r (@arr){
            my @tmp = @{$t_r};
            if($j eq "seq"){
                if(exists $len{$tmp[0]}){
                    my $q_len = $len{$tmp[0]};
                    my $blst_i  = $tmp[1]/100;
                    my $blst_c  = ($tmp[2])/$q_len;
                    if($blst_i>=$ident and $blst_c>=$cov){
                        push @arr_n , [$tmp[3],$tmp[4]];
                    }
                }else{
                    print STDERR "$tmp[0]: can't load length\n";
                    exit;
                }
            }else{
                my $blst_i  = $tmp[1]/100;
                if($blst_i >= $ident){
                    push @arr_n , [$tmp[3],$tmp[4]];
                }
            }
        }
        @arr_n = sort{${$b}[0] <=> ${$a}[0]} @arr_n;
        #print (join ";",@{$_}) for @arr_n;exit;
        my $num = scalar @arr_n;
        if($num > $max_target){
            for(my $i = 0;$i < ($max_target);$i++){
                print ${$arr_n[$i]}[1];
                
            }
        }else{
            for(my $i = 0;$i < ($num);$i++){
                print ${$arr_n[$i]}[1];
            }
        }
    }
}

sub print_help{
    print STDERR "\nUSAGE : perl $0 --blast blast_res --max_target [1] --ident seq_ident [0.4] --mode [query|target] (--seq query_pep --cov seq_coverage [0.4])\n\n";
    
}

sub load_fasta{
    my $pep = shift @_;
    my %h;
    my $s_obj = Bio::SeqIO -> new(-file => $pep);
    while(my $s_io = $s_obj -> next_seq){
        my $id =$s_io -> display_id;
        my $len = $s_io -> length;
        $h{$id} = $len;
    }
    return %h;
}
