#! perl

use warnings;
use strict;
use File::Basename;
use Cwd qw/abs_path getcwd/;
use Bio::SeqIO;

if(scalar @ARGV < 3){
    print "USAGE : perl $0 \$f_sub \$f_homo \$f_alignment \$f_seq \$output\n";
    exit;
}
#$f_homo //= "z.homopair.txt";
#$f_alignment //= "Brup5-Bsyl.alignment.homo_filter.csv";

my $f_sub = shift;
my $f_homo = shift;
my $f_alignment = shift;
my $f_seq = shift;
my $d_output = shift;

$d_output //= "z.homopair_tree";
$f_seq //= "All.cds";

my $h_dir = getcwd();
$f_sub = abs_path($f_sub);
$f_homo = abs_path($f_homo);
$f_alignment = abs_path($f_alignment);
$d_output = abs_path($d_output);
$f_seq = abs_path($f_seq);

my %r1 = &load_subgenome($f_sub);
my %r2 = &load_homo($f_homo); 
my %r3 = &load_alignment($f_alignment);
my %s = &load_seq($f_seq);

mkdir $d_output if !-e $d_output;
chdir $d_output;
my $cc = 0;
my $cc1 = 0;
open O2,'>',"gene.lst";
open O3,'>',"chain.lst";
for my $k (sort {$a cmp $b} keys %r2){
    if(!exists $r3{$k}){
        print STDERR "$k\n";
        exit;
    }
    my @g_lst_a = @{$r3{$k}};
    my $cc2 = scalar @g_lst_a;
    print O3 "$cc1\t$cc2\t$k\n";
    my $tt = "chain".$cc1;
    mkdir $tt if ! -e $tt;
    chdir $tt;
    mkdir "split_gene" if ! -e "split_gene";
    chdir "split_gene";
  D:for(my $i = 0;$i < @g_lst_a;$i ++){
      my @g_lst = split/,/,$g_lst_a[$i];
      my $n = join"-",@g_lst;
      my $p;
      for my $g (@g_lst){
	  (my $g_c = $g) =~ s/g.*//;
	  $p .= ">$r1{$g_c}\n";
	  my $ss = $s{$g};
	  if ($ss =~ /[Nn]/){
		print O2 "$cc\t$n\terror\t$g\n";
		$cc += 1;
		next D;
	  }else{
	      $p .= "$s{$g}\n";
	  }
	}
      mkdir "gene".$cc if !-e "gene".$cc;
      chdir "gene".$cc;
      open O,'>',"cds.fa";
      print O $p;
      close O;
      chdir "$d_output/$tt/split_gene";
      print O2 "$cc\t$n\tok\tNA\n";
      $cc += 1;
      #exit;
  }
    $cc1 += 1;
    chdir $d_output;
}
close O2;
close O3;
chdir $h_dir;

sub load_subgenome{
    my $f = shift;
    open IN,'<',$f;
    my %h;
    while(<IN>){
	chomp;
	my @l = split/\t/;
	if(exists $h{$l[0]}){
	    print "dup sequence in $f: $l[0]\n";
	}
	$h{$l[0]} = $l[1];
    }
    return %h;
}

sub load_alignment{
    my $f = shift;
    open IN,'<',$f;
    my %h;
    while(<IN>){
	chomp;
	my @l = split/,/;
	my @gs;
	for my $g (@l){
	    $g =~ s/g.*//;
	    push @gs, $g;
	}
	@gs = sort {$a cmp $b} @gs;
	my $at = join"-",@gs;
	push @{$h{$at}} ,$_;  
    }
    return %h;
}
sub load_homo{
    my $f = shift @_;
    my %h;
    open IN,'<',$f;
    while(<IN>){
	chomp;
	my @l = split/\t/;
	@l = sort{$a cmp $b} @l;
	my $t = join"-",@l;
	$h{$t} = 1;
    }
    close IN;
    return(%h);
}

sub load_seq{
    my $f = shift @_;
    my $s_obj = Bio::SeqIO -> new (-file => $f , -format => "fasta");
    my %h;
    while(my $s = $s_obj -> next_seq){
        my $id = $s -> display_id;
        my $seq = $s -> seq;
	$h{$id} = $seq;
    }
    return %h;
}
