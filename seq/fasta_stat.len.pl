#! perl

use strict;
use warnings;
use Bio::SeqIO;
use Getopt::Long;
use File::Basename;
use List::Util qw(max min);

my ($help,$ref,$start,$bed,$mark,$tt);
GetOptions(
           'ref=s' => \$ref,
           'help' => \$help,
           'start=s' => \$start,
           'bed' => \$bed,
           'mark=s' => \$mark,
           'rep_mark=s' => \$tt,
          );
$start //= 1;
$mark //= "N";
$tt //= ":";

if($help){
    &print_help();
    exit;
}

if(@ARGV != 0){
    if(! -e $ref){
        print STDERR "need a fasta file \n\n";
	    &print_help();
        exit;
    }
}else{
    &print_help();
    exit;
}

my @mm = split/,/,$ARGV[0];
(my $nn = basename $ref);

for my $item (@mm){
    my $j = 0;
    if ($item eq "len"){
        my $rr = &load_fasta($ref);
        my @p = @{&stat_len($rr)};
        open O,'>', "$nn\.len.txt";
        print O $_ for @p;
        close O; 
        $j += 1;
        undef $rr;
    }
    if ($item eq "Nlen_stat"){
        my $rr = &load_fasta($ref);
        my @p = @{&stat_len_N($rr)};
        open O,'>',"$nn\.stat\_$mark.txt";
        print O $_ for @p;
        close O; 
        $j += 1;
        undef $rr;
    }
    if ($item eq "Nlen_count"){
        my $rr = &load_fasta($ref);
        my @p = @{&stat_number_N($rr)};
        open O,'>',"$nn\.count\_$mark.txt";
        print O $_ for @p;
        close O; 
        $j += 1;
        undef $rr;
    }
    if($j == 0){
        &print_help();
        exit;
    }

}

sub stat_len_N{
    my $s_obj = shift @_;
    my @res;
    while(my $s_io = $s_obj-> next_seq){
        my $id = $s_io -> display_id;
        my $seq = $s_io -> seq;
	#my $ll = $s_io -> len;
        $seq = uc($seq);
        my @t;
        
        (my $seq1 = $seq);
        $seq1 = eval "\$seq1 =~ tr/$mark/$tt/csr";
        (my $seq2 = $seq);
        $seq2 = eval "\$seq2 =~ tr/$mark/$tt/sr";
        
        if ($seq =~ /^$mark/){
            $seq2 =~ s/$tt//;
            @t = &stat_len_N_sub1(\$seq1,\$seq2);
        }
        if ($seq =~ /^[ATCG]/){
            $seq1 =~ s/$tt//;
            @t = &stat_len_N_sub1(\$seq2,\$seq1);
        }
        my $c1 = 1;
        my $c2 = 0;
        for my $e (@t){
            my $k = ($e =~/^$mark/)?"GAP":"SEQ";
            $c2 += length($e);
            push @res, "$id\t$c1\t$c2\t$k\n";
            $c1 += length($e);
        }
    }
    return \@res;
}

sub stat_len_N_sub1{
    my ($r1,$r2) =  @_;
    my @s1 = split/:/,${$r1};
    my @s2 = split/:/,${$r2};
    #print join"\n",@s2;exit;
    my @p;
    my $n1 = scalar @s1;
    my $n2 = scalar @s2;
    my $min = min($n1,$n2);
    my $d = $n1 - $n2;
    for(my $i = 0;$i < $min;$i+=1){
        push @p,$s1[$i];
        push @p,$s2[$i];
    }
    if($d == 0){
        return @p;
    }elsif($d > 0){
        for(my $i = $n2;$i<$n1;$i+=1){
            push @p , $s1[$i];
        }
        return @p;
    }elsif($d < 0){
        for(my $i = $n1;$i<$n2;$i+=1){
            push @p , $s2[$i];
        }
        return @p;
    }
}

sub stat_number_N{
    my $s_obj = shift @_;
    my @res;
    while(my $s_io = $s_obj -> next_seq){
        my $id = $s_io -> display_id;
        my $seq = $s_io -> seq;
        my $len = $s_io -> length;
        $seq = uc($seq);
        my @l = split /$mark{1,}/,$seq;
        $seq =~ s/$mark//g;
	my $n1 = length $seq;
        my $n2 = $len - $n1;
        push @res, "$id\t$len\t$n1\t$n2\t".(scalar @l -1)."\n";
    }
    return \@res
}

sub stat_len{
    my $s_obj = shift @_;
    my @res;
    while(my $s_io = $s_obj -> next_seq){
        my $id = $s_io -> display_id;
        my $len = $s_io -> length;
        $len = $len + $start - 1;
        if($bed){
            push @res, "$id\t$start\t$len\n";
        }else{
            push @res ,"$id\t$len\n";
        }
    }
    return(\@res)
}


sub load_fasta{
    my $ss = Bio::SeqIO -> new (-file => shift , -format => "fasta");
    return $ss
}

sub print_help{
    print STDERR "USAGE : perl $0 [len|Nlen_stat|Nlen_count] --ref [ref_file] \$fasta --start [0|1] --bed (--mark N --rep_mark :)\n";
}
