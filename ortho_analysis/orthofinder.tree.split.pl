#! perl

use warnings;
use strict;
use File::Basename;
use Cwd qw/abs_path getcwd/;
use Bio::SeqIO;

if(scalar @ARGV != 4){
    print STDERR "USAGE : perl $0 \$og_group \$og_table \$cds_dir [cds.fa] \$pep_dir [pep.fa]\n";
    exit;
}

my $h_dir = getcwd;

my ($f_ref,$f_og,$d_cds,$d_pep) = @ARGV;

my %hc = load_seq($d_cds,"cds");
my %hp = load_seq($d_pep,"pep");

my %href = load_table($f_ref);

open IN,'<',$f_og;
my $l_first = readline IN;
$l_first =~ s/\r//;
$l_first =~ s/\n//;
my @header = split/\t/,$l_first;

mkdir "1.split" if !-e "1.split";

while(<IN>){
    $_ =~ s/\r//;
    $_ =~ s/\n//;
    my @l = split/\t/;
    next if ! exists $href{$l[0]};
    mkdir "1.split/$l[0]" if !-e "1.split/$l[0]";
    chdir "1.split/$l[0]";
    open O1,'>',"cds.fa";
    open O2,'>',"pep.fa";
    for(my $i = 1;$i < @l;$i ++){
	if(!exists $hc{$header[$i]}{$l[$i]}){
	    die "40 : cds : $l[0]: $l[$i] not exists\n";
	}
	if(!exists $hp{$header[$i]}{$l[$i]}){
            die "40 : pep : $l[0] : $l[$i] not exists\n";
        }
	print O1 ">".$header[$i]."\n".$hc{$header[$i]}{$l[$i]}."\n";
	print O2 ">".$header[$i]."\n".$hp{$header[$i]}{$l[$i]}."\n";
    }
    close O1;
    close O2;
    chdir $h_dir;
}

sub load_table{
    my $f = shift @_;
    my %h;
    open IN,'<',$f;
    while(<IN>){
	s/\r//;
	s/\n//;
	my @l = split/\t/;
	$h{$l[0]} = $l[0];
    }
    close IN;
    return %h;
}

sub load_seq{
    my $d = shift @_;
    my $rex = shift @_;
    my $d_d = abs_path($d); 
    #my @f_fs = grep {/$rex.fa$/} `ls $d`;
    my @f_fs = grep {/.fa$/} `ls $d`;
    my %h;
    for my $f (@f_fs){
	chomp $f;
	(my $sp = basename $f) =~ s/\..*//;
	$f = "$d_d/$f";
	my $seqio_obj = Bio::SeqIO -> new(-file => $f, -format =>"fasta");
	while(my $seq_obj = $seqio_obj -> next_seq){
	    my $id = $seq_obj -> display_id;
	    my $seq = $seq_obj -> seq;
	    if($seq =~ /\*$/){
		$seq =~ s/\*$//;
	    }
	    if(exists $h{$sp}{$id}){
		print "$f : duplicate_id : $id\n";
		exit;
	    }
	    $h{$sp}{$id} = $seq;
	}
    	undef $seqio_obj;
    }
    return %h;
}
