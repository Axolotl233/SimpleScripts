#! perl

use warnings;
use strict;
use List::Util qw/uniq/;
no warnings 'recursion';

my @d;

for my $f(@ARGV){
    open IN,'<',$f or die "$!";
    while(<IN>){
	chomp $_;
	my @l = split/\t/;
	@l = sort @l;
	push @d, (join"-",@l);
    }
    close IN;
}
@d = uniq(sort @d);

my %count;
for my $line (@d){
    my @tt = split/-/,$line;
    for my $t (@tt){
	$count{$t} += 1;
   }
}
my $c1 = 0;
my %table;

for my $line (@d){
    my @tt = split/-/,$line;
    my $jud = 0; 
    for my $t (@tt){ 
	if($count{$t} != 1){ 
	    $jud += 1; 
	} 
    } 
    if($jud == 0){ 
	print join"\t",@tt; 
	print "\n"; 
    }else{
	@{$table{$c1}} = @tt;
	$c1 += 1;
    }
}

my $total_num = scalar keys %table;

for my $i(sort {$a <=> $b} keys %table){
    next if !exists $table{$i};
    my $con = 0;
    my @t1 = @{$table{$i}};
  D3:while($con != 1){
      my %h;
      for my $t (@t1){
	  $h{$t} = 1;
      }
      my @t2 = @t1;
    D4:for(my $j = $i + 1;$j < $total_num;$j += 1){
	next if !exists ($table{$j});
	my @arr = @{$table{$j}};
	for my $t2(@arr){
            if(exists $h{$t2}){
                @t2 = uniq(sort(@t2,@arr));
                delete $table{$j};
                last D4;
            }
        }
    }
      $con = 1 if scalar @t2 == scalar @t1;
      last D3 if ($con == 1);
      @t1 = @t2;
  }
    print join"\t",@t1;
    print "\n";
    delete $table{$i};
}
