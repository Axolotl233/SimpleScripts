#! perl

use warnings;
use strict;
use File::Basename;
use Cwd qw/abs_path getcwd/;
use Bio::SeqIO;

if(@ARGV < 1){
    print STDERR "USAGE : perl $0 \$sp[sp1,sp2,sp3] \$dir[cds,pep,gff]\n";
    print STDERR "cds|pep must named as sp.clean.cds|pep.fa, gff must named as sp.gff\n";
    exit;
}

my $sp_para = shift;
my @sp = split/,/,$sp_para;

my $dir = shift;
$dir //= "/home/wenjie/database/clean_cds_pep_data";
$dir = abs_path $dir;

for my $s (@sp){
    my $f_cds = "$dir/$s.clean.cds.fa";
    my $f_pep = "$dir/$s.clean.pep.fa";
    my $f_gff = "$dir/$s.gff";
    unless(-e $f_cds && -e $f_pep && -e $f_gff){
	print STDERR "input incomplete: $s\n";
	next;
    }
    my %h;
    
    my $t = `wc -l $f_gff`;
    $t =~ s/ .*\n//;
    my $tmp_l = abs(length $t);

    my $c = 1;
    open IN,'<',$f_gff or die "$!";
    my $l_first = readline IN;
    my @l = split/\t/,$l_first;
    $l[0] =~ s/[_|-]//;
    my $chr = $l[0];
    my $n_name = $chr."g".sprintf("%0*d", $tmp_l, $c);
    #my $n_name = $chr."g".substr("0"x $tmp_l.$c, -$tmp_l);
    $h{$l[3]} = $n_name;

    open O,'>',"$s.wgdi.gff";
    open O2,'>',"$s.wgdi.lens";

    my $len = abs($l[2] - $l[1]) + 1;

    my @p = ($l[0],$n_name,$l[1],$l[2],$l[4],$c,$l[3]);
    print O join"\t",@p;
    print O "\n";
    
    while(<IN>){
	$c = $c + 1;
	chomp;
	my @l = split/\t/,$_;
	$l[0] =~ s/[_|-]//;
	
	if($l[0] ne $chr){
	    $c = $c - 1;
	    print O2 "$chr\t$len\t$c\n";
	    $c = 1;
	    $len = 0;
	    $chr = $l[0];
	}
	
	my $n_name = $l[0]."g".sprintf("%0*d", $tmp_l, $c);
	#my $n_name = $chr."g".substr("0"x $tmp_l.$c, -$tmp_l);
	$h{$l[3]} = $n_name;
	$len = $len + abs($l[2] - $l[1]) + 1;
	my @p = ($l[0],$n_name,$l[1],$l[2],$l[4],$c,$l[3]);
	print O join"\t",@p;
	print O "\n";
    }
    close IN;
    $c = $c - 1;
    print O2 "$chr\t$len\t$c\n";
    close O;
    close O2;
    &phase_fasta($f_cds,\%h,"$s.wgdi.cds");
    &phase_fasta($f_pep,\%h,"$s.wgdi.pep");
}

sub phase_fasta{
    my $f_i = shift @_;
    my $ref = shift @_;
    my %r = %{$ref};
    my $f_o = shift @_;
    my $seqio_obj = Bio::SeqIO -> new(-file => $f_i , -format =>"fasta");
    open OO,'>',$f_o;
    while(my $seq_obj = $seqio_obj -> next_seq){
	my $o_id = $seq_obj -> display_id;
	my $seq = $seq_obj -> seq;
	my $id;
	if(exists $r{$o_id}){
	    $id = $r{$o_id};
	}else{
	    next;
	}
	print OO ">$id\n$seq\n";
    }
    close OO;
}
