#! perl

use warnings;
use strict;
use MLoadData;

if(scalar @ARGV != 1){
    print STDERR "\nPlease run \`perl paf_filter.base_homo.pl\` and \`perl paf_filter.base_length.pl` to filter paf file [optional]\n";
    print STDERR "\nPlease split paf file based on target sequecne name, each file for input should just contain one target sequence [necessary] ";
    print STDERR "[perl /home/wenjie/code/file/split_file_by_col.pl \$paf --key_col 5]\n";
    print STDERR "\nUSAGE: perl $0 \$split.paf\n";
    exit;
}

my $paf = shift;
my @paf_d = MLoadData::load_from_file($paf);
my @paf_info = @{&pre_reformat_paf(\@paf_d)};
my @paf_info_s = sort {$a->[1] <=> $b->[1]} @paf_info;
my %h = %{&block_split(\@paf_info_s)};

for(my $j = 0; $j < scalar (keys %h);$j += 1){
    my @p = @{&block_cal(\@{$h{$j}})};
    print $_."\n" for @p;
    print "#\n";
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
    my @dd_r;
    for (my $i = 0;$i < @dd;$i ++){
        my @l = split/\t/,$dd[$i];
        $dd_r[$i] = [$dd[$i],$l[7]];
    }
    return (\@dd_r);
}

