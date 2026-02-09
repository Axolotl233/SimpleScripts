#! perl

use warnings;
use strict;
use List::Util qw/uniq/;
use Math::Combinatorics;
no warnings 'recursion';

my $f1 = shift;
my $f2 = shift;
my $mode = shift;
$mode //= "filter";

my @d1 = load_data($f1,0,1);
my @d2 = load_data($f2,1,0);

my %pair1 = %{$d1[0]};
my %pair2 = %{$d2[0]};

my @d = (@{$d1[1]},@{$d2[1]});
@d = uniq(sort {$a cmp $b} @d);

my %count;
my %table1;
my $i2 = 0;
for (my $i = 0;$i < scalar @d;$i += 1){
    my @d_t = split/-/,$d[$i];
    $count{$_} += 1 for @d_t;
    @{$table1{$i}} = @d_t;
}
my $j = 0;
my %table2;

for my $i(sort {$a <=> $b} keys %table1){
    my $t3 = 0;
    my @t1 = @{$table1{$i}};    
    pop @t1 if ($t1[1] eq "\.");
    D4:for my $t4(@t1){
        if($count{$t4} > 1){
            $t3 += 1;
            last D4;
        }
    }
    if($t3 == 0){
	print join"\t",@t1;
	print "\n";
    }else{
	@{$table2{$j}} = @t1;
	$j = $j += 1;
    }
}

my $total_num = scalar keys %table2;

for my $i(sort {$a <=> $b} keys %table2){
    next if !exists $table2{$i};
    my @t1 = @{$table2{$i}};
    my $con = 0;
    D3:while($con != 1){
	my @t2 = &merge_table($i+1,\@t1);
	$con = 1 if scalar @t2 == scalar @t1;
	last D3 if $con == 1;
	@t1 = @t2;
    }
    if(scalar @t1 > 2){
	my %tt = &split_table(\@t1);
	for my $k (sort {$a <=> $b} keys %tt){
	    print join"\t",@{$tt{$k}};
	    print "\n";
	}
    }else{
	print join"\t",@t1;
	print "\n";
    }
    delete $table2{$i};
}

sub split_table{
    my $ref = shift @_;
    my @arr = @{$ref};
    my %h;
    for my $t (@arr){
        $h{$t} = 1;
    }
    my %t_res;
    my $e = 0;
    #my $e = 1;
    my @arr_c = combine(2,@arr);
    for(my $i = 0;$i< @arr_c;$i++){
        my @arr_t = @{$arr_c[$i]};
        my $c1 = "$arr_t[0]-$arr_t[1]";
        my $c2 = "$arr_t[1]-$arr_t[0]";
        if(exists $pair1{$c1} && exists $pair2{$c2}){
            exists $h{$arr_t[0]}?delete $h{$arr_t[0]}:die join"\t",@arr;
            exists $h{$arr_t[1]}?delete $h{$arr_t[1]}:die join"\t",@arr;
            @{$t_res{$e}} = sort{$a cmp $b}($arr_t[0],$arr_t[1]);
            $e += 1;
        }elsif(exists $pair1{$c2} && exists $pair2{$c1}){
            exists $h{$arr_t[0]}?delete $h{$arr_t[0]}:die join"\t",@arr;
            exists $h{$arr_t[1]}?delete $h{$arr_t[1]}:die join"\t",@arr;
            @{$t_res{$e}} = sort{$a cmp $b}($arr_t[0],$arr_t[1]);
            $e += 1;
        }
    }
    if($mode eq "no_filter"){
	if(scalar (keys %h) == 2){
	    my @th= sort{$a cmp $b} keys %h;
	    @{$t_res{$e + 2}} = $th[0];
	    @{$t_res{$e + 1}} = $th[1];
	}else{
	    @{$t_res{0}} = sort{$a cmp $b} keys %h;
	}
    }
    return %t_res;
}

sub merge_table{
    my $index = shift @_;
    my $ref = shift @_;
    my @arr = @{$ref};
    my %h;
    for my $t (@arr){
        $h{$t} = 1;
    }
    D1:while($index < $total_num){
      if(!exists $table2{$index}){
	  $index = $index + 1;
      }else{
	  my @arr_t = @{$table2{$index}};
	D2:for my $t2(@arr_t){
	    if(exists $h{$t2}){
		@arr = (@arr,@arr_t);
		delete $table2{$index};
		last D2;
	    }
	}
	  @arr = uniq(@arr);
	  @arr = &merge_table($index+1,\@arr);
	  last D1;
      }
    }
    return @arr;
}

sub load_data{
    my $f = shift @_;    
    my $c1 = shift @_;
    my $c2 = shift @_;

    my @ll;
    my %h;
    my $cc = 0;

    open IN,'<',$f or die "$!";
    while(<IN>){
        chomp $_;
        my @l = split/,/;
        if(scalar @l > 2){
            print "$f:$/:$_\n";
            exit;
        }
        $l[1] = "." if (scalar @l == 1);
	if($l[1] eq "."){
	    $ll[$cc] = "$l[0]-$l[1]";
	}else{
	    $ll[$cc] = "$l[$c1]-$l[$c2]";
	    $h{"$l[0]-$l[1]"} = 1;
	}
        $cc += 1;
    }
    close IN;
    return (\%h,\@ll);
}
