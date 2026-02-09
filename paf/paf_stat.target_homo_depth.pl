#! perl

use warnings;
use strict;
use MLoadData;
use MCE::Loop;
use File::Basename;
use Getopt::Long;
use Cwd;

my $h_dir = getcwd();
my($seq_t,$paf,$len_o,$len_q,$len_m,$thread);
GetOptions(
           'seq_target=s' => \$seq_t,
           'paf=s' => \$paf,
           'min_length_out=s' => \$len_o,
           'min_length_query=s' => \$len_q,
           'min_length_match=s' => \$len_m,
           'thread=s' => \$thread
          );
$len_q //= 100000;
$len_m //= 10000;
$len_o //= 10000;
$thread //= 1;

if(! $paf || !$seq_t){
    print STDERR "USAGE: perl $0 --seq_target seq.lst --paf paf [--thread 1 --min_length_out 10000 --min_length_query 100000 --min_length_match 10000]\n";
    exit;
}

(my $paf_n = basename $paf) =~ s/\.paf//;
my %r = MLoadData::load_from_file_hash($seq_t);
my @info_paf = MLoadData::load_from_file($paf);
my %d = %{&pre_reformat_paf(\@info_paf)};

my $o_dir = "$h_dir/$paf_n\.homo_depth_stat";
mkdir $o_dir unless -e $o_dir;

if($thread > 1){
    MCE::Loop::init {max_workers => $thread, chunk_size => 1};
    mce_loop {&run($_)} (keys %d);
}else{
    for my $k (keys %d){
        &run($k)
    }
}

sub run{
    my $rr = shift @_;
    my @ddd = @{$d{$rr}};
    my @ddd_s = sort {$a->[1] <=> $b->[1]} @ddd;
    my %hh = %{&block_split(\@ddd_s)};
    
    open my $oh,'>',"$o_dir/$rr.homo_depth.txt";
    for(my $j = 0; $j < scalar (keys %hh);$j += 1){
        my @p = @{&block_cal(\@{$hh{$j}})};
        print $oh $_."\n" for @p;
	print $oh "#\n";
    }
    close $oh;
}

sub block_cal{
    my $ref_bc = shift @_;
    my @dd_bc = @{$ref_bc};
    my ($global_min, $global_max) = (undef, undef);
    my %h_bc;
    my @res;
    for my $t_bc (@dd_bc){
        my @l_bc = split/\t/,$t_bc;
        $global_min = defined $global_min ? ($l_bc[7] < $global_min?$l_bc[7]:$global_min):$l_bc[7];
        $global_max = defined $global_max ? ($l_bc[8] > $global_max?$l_bc[8]:$global_max):$l_bc[8];
        for (my $ij = $l_bc[7];$ij <= $l_bc[8]; $ij += 1){
            push @{$h_bc{$ij}} , $l_bc[0];
        }
    }
    my @t_first = sort {$a cmp $b} @{$h_bc{$global_min}};
    my $r_first = join",",@t_first;
    my $pos_first = $global_min;
    for(my $kk = $global_min + 1; $kk <= $global_max; $kk += 1){
         my @t = sort {$a cmp $b} @{$h_bc{$kk}};
         my $r = join",", @t;
         if($r ne $r_first){
            push @res,"$pos_first\t$kk\t$r_first";
            $r_first = $r;
            $pos_first = $kk;
         }
    }
    push @res,"$pos_first\t$global_max\t$r_first";
    return \@res;
}

sub block_split{
    my $ref_bs = shift @_;
    my @dd_bs = @{$ref_bs};
    my %h_bs;
    my $c = 0;
    my @l0 = split/\t/,$dd_bs[0]->[0];
    my @tmp = ($l0[7],$l0[8]);
    push @{$h_bs{$c}}, $dd_bs[0]->[0];
    
    for (my $i = 1; $i < @dd_bs;$i += 1){
        my @l1 = split/\t/,$dd_bs[$i]->[0];
        if($tmp[1] >= $l1[7] && $l1[8] >= $tmp[0]){
            $tmp[0] = ($l1[7] > $tmp[0])? $tmp[0]:$l1[7];
            $tmp[1] = ($l1[8] > $tmp[1])? $l1[8]:$tmp[1];
            push @{$h_bs{$c}}, $dd_bs[$i]->[0];
        }else{
            @tmp = ($l1[7],$l1[8]);
            $c += 1;
            push @{$h_bs{$c}}, $dd_bs[$i]->[0];
        }

    }
    return \%h_bs;
}

sub pre_reformat_paf{
    my $ref = shift @_;
    my @dd = @{$ref};

    my %h;
    for my $dd_i (@dd){
        my @l = split/\t/,$dd_i;
        next if (! exists $r{$l[5]});
        next if ($l[10] < $len_m);
        next if ($l[1] < $len_q);
        if($l[2] > $l[3]){
            print "wrong query start and end\n";
            exit;
        } 
        if($l[7] > $l[8]){
            print "wrong target start and end\n";
            exit;
        } 
        push @{$h{$l[5]}}, [$dd_i,$l[7]];
    }
    return \%h;
}
