#! perl

use warnings;
use strict;
use File::Basename;

if(scalar @ARGV < 2){
    print STDERR "USAGE : perl $0 \$sp1.cds.bed \$sp2.cds.bed [\$chr_lst]\n";
    exit;
}
my $f1 = shift;
(my $n1 = basename $f1) =~ s/\..*//;
my $f2 = shift;
(my $n2 = basename $f2) =~ s/\..*//;

my %r;
my @chr;

if(scalar @ARGV > 0){
    @chr = @{&load_chr($ARGV[0])};
}else{
    my $tmp = `cat $f1 $f2|cut -f 1 |sort |uniq`;
    chomp $tmp;
    @chr = split/\n/,$tmp;
}

$r{$_} = 1 for @chr;
my %h1 = %{load_cds_bed($f1)};
my %h2 = %{load_cds_bed($f2)};

open O1,'>',"$n1-$n2.overlap.txt";
for my $s(@chr){
    D:for my $g1(sort {$a cmp $b} keys %{$h1{$s}}){
	my @ref1 = @{$h1{$s}{$g1}};
	for my $g2 (sort {$a cmp $b} keys %{$h2{$s}}){
	    my @ref2 = @{$h2{$s}{$g2}};
	    if($ref1[0] <= $ref2[1] && $ref2[0] <= $ref1[1]){
		my @p = ($s,$g1,$g2,"$ref1[0]-$ref1[1]","$ref2[0]-$ref2[1]");
		if($ref1[2] eq $ref2[2]){
		    push @p, "="
		}else{
		    push @p, &compare_cds($ref1[2],$ref2[2]);
		}
		delete $h2{$s}{$g2};
		delete $h1{$s}{$g1};
		print O1 join"\t",@p;
		print O1 "\n";
		next D;
	    }
	}
    }
}

sub compare_cds{
    my $c1 = shift @_;
    my $c2 = shift @_;
    my @arr1 = split/;/,$c1;
    my @arr2 = split/;/,$c2;
    my %hh1;
    my %hh2;
    $hh1{$_} = 1 for @arr1;
    $hh2{$_} = 1 for @arr2;
    my $d1 = 0;
    my $d2 = 0;
  DD:for my $k1 (sort {$a cmp $b} keys %hh1){
      my @pos1 = split/-/,$k1;
      for my $k2 (sort {$a cmp $b} keys %hh2){
	  my @pos2 = split/-/,$k2;
	  if($pos1[0] <= $pos2[1] && $pos2[0] <= $pos1[1]){
	      if($pos1[0] == $pos2[0] && $pos1[1] == $pos2[1]){
		  $d1 += 1;
	      }else{
		  $d2 += 1;
	      }
	      delete $hh1{$k1};
	      delete $hh2{$k2};
	      next DD;
	  }
      }
  }
    my $d3 = scalar keys %hh1;
    my $d4 = scalar keys %hh2;
    return join":",($d1,$d2,$d3,$d4);
}
    
sub load_chr{
    my $f = shift @_;
    my %h;
    open IN,'<',$f;
    while(<IN>){
	chomp;
	my @l = split/\t/;
	$h{$l[0]} += 1;
    }
    close IN;
    my @t = sort {$a cmp $b} keys %h;
    return \@t;
}

sub load_cds_bed{
    my $f = shift @_;
    my %h;
    open IN,'<',$f;
    while(<IN>){
	chomp;
        my @l = split/\t/;
	next if !exists $r{$l[0]};
	$h{$l[0]}{$l[2]} = [$l[3],$l[4],$l[10]];
    }
    close IN;
    return \%h;
}
