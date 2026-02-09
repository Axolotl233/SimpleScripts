#! perl

use warnings;
use strict;
use Math::Combinatorics;
use List::Util qw/sample shuffle/;
use MCE::Loop;

if(scalar @ARGV < 1){
    print STDERR "USAGE: perl $0 Orthogroups.GeneCount.tsv [sample_size]\n\n";
    exit;
}

my $f = shift;
my $tt = shift;
$tt //= 100;
open IN,'<',$f;

my $first = readline IN;
my @head = split/\t/,$first;
pop @head;
my @sp = @head;
shift @sp;
my $sp_n = scalar @sp;
my %h;

while(<IN>){
    chomp;
    my @l = split/\t/;
    pop @l;
    for(my $i = 1;$i < @l;$i ++){
	$h{$l[0]}{$head[$i]} = $l[$i];
    }
}
close IN;

mkdir "z.tmp" if ! -e "z.tmp";
MCE::Loop::init {max_workers => 16, chunk_size => 1};
mce_loop {&run($_)} (1..$sp_n);

sub run{
    my $i = shift @_;
    my @sp_com = combine($i,@sp);
    my $n = scalar @sp_com;
    if($n > $tt){
	@sp_com = sample $tt, @sp_com;
    }
    open my $fh,'>',"z.tmp/$i.txt";
  D:for my $t (@sp_com){
      my $pan_n = 0;
      my $core_n = 0;
      my @sps = @{$t};
      for my $k(keys %h){
	  my $j = 1;
	  my $q = 0;
	  for my $tmp_sp (@sps){
	      $j = $j * $h{$k}{$tmp_sp};
	      $q = $q + $h{$k}{$tmp_sp};
	  }
	  if($i == 1){
	      $pan_n += 1 if $j != 0;
	  }else{
	      $pan_n += 1 if $q != 0;
	      $core_n += 1 if $j != 0;
	  }
      }      
      print $fh "$i\tpan\t$pan_n\n";
      print $fh "$i\tcore\t$core_n\n";
  }
    close $fh;    
}
