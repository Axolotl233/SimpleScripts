#!/usr/bin/perl
use strict;
use warnings;
use File::Basename;
use FindBin qw($Bin);

my ($evm_dir,$abinitio_dir,$homolog_dir,$rna_dir,$genome_dir,$outdir)=@ARGV;

die "perl $0 evm_dir abinitio_dir homolog_dir rna_dir genome_dir outdir\n" if (! $outdir);
mkdir $outdir if ! -e $outdir;

my %gff;
my %weight;
my @abinitio=<$abinitio_dir/*/results/*gff>;
my @homolog=<$homolog_dir/*/final_annotation.gff.for.evm>;
my @chr=<$genome_dir/*fa>;

for my $abgff (@abinitio){
    $abgff=~/1.abinitio\/(\S+)\/results\// or die "$abgff";
    my $soft=$1;
    $soft=lc($soft);
    $weight{ABINITIO_PREDICTION}{$soft}++;
    open (F,"$abgff")||die"$!";
    while (<F>){
	chomp;
	next if /^#/;
	next if /^\s*$/;
	my @a=split(/\s+/,$_);
	$a[1]=$soft;
	$gff{ab_initio}{$a[0]}{$soft} .= join("\t",@a)."\n";
    }
    close F;
}
for my $hogff (@homolog){
    $hogff=~/2.homologs\/gemoma\/([\w.]+)\.results\// or die "$hogff";
    my $soft=$1;
    $soft=lc($soft);
    $weight{PROTEIN}{$soft}++;
    my $lastcontig="NA";
    open (F,"$hogff")||die"$!";
    while (<F>){
	chomp;
        my @a=split(/\s+/,$_);
	if (/^\s*$/){
	    next if $lastcontig eq "NA";
	    $gff{homolog}{$lastcontig}{$soft} .= join("\t",@a)."\n";
	}else{
	    $a[1]=$soft;
	    $gff{homolog}{$a[0]}{$soft} .= join("\t",@a)."\n";
	    $lastcontig=$a[0];
	}
    }
    close F;
}
## transcriptome miss##
if ($rna_dir ne "NA"){
    my $soft="RNA_SEQ";
    my @rnaseqgff=<$rna_dir/*gff3 $rna_dir/*gff>;
    $weight{TRANSCRIPT}{$soft}++;
    for my $rnaseqgff (@rnaseqgff){
	my $lastcontig="NA";
	open (F,"$rnaseqgff") || die "cant open $rnaseqgff";
	while (<F>){
	    chomp;
#	    next unless length;
	    my @a=split(/\s+/,$_);
	    if (/^\s*$/){
		next if $lastcontig eq "NA";
		$gff{rna_seq}{$lastcontig}{$soft} .= join("\t",@a)."\n";
	    }else{
		$a[1]=$soft;
		$gff{rna_seq}{$a[0]}{$soft} .= join("\t",@a)."\n";
		$lastcontig=$a[0];
	    }
	}
	close F;  
    }
}

my %rr = load_config("$Bin/EVM_weights.template.txt");

open (O,">$outdir/evm.weights.txt");
for my $k1 (sort keys %weight){
    for my $k2 (sort keys %{$weight{$k1}}){
	if(exists $rr{"$k1-$k2"}){
	    my $t = $rr{"$k1-$k2"};
	    print O "$k1\t$k2\t$t\n";
	}else{
	    print O "$k1\t$k2\t10\n";
	}
    }
}
close O;

`mkdir $outdir/evm_for_each_chr` if (! -e "$outdir/evm_for_each_chr");
for my $chrfa (@chr){
    $chrfa=~/\/([\w.]+)\.fa$/ or die "$chrfa";
    my $chr=$1;
    `mkdir $outdir/evm_for_each_chr/$chr` if (! -e "$outdir/evm_for_each_chr/$chr");
    #for my $type (sort keys %gff){
    for my $type ("ab_initio","homolog","rna_seq"){
	open (O,">$outdir/evm_for_each_chr/$chr/$type.gff");
	for my $soft (sort keys %{$gff{$type}{$chr}}){
	    print O "$gff{$type}{$chr}{$soft}";
	}
	close O;
    }
}
sub load_config{
    my $f = shift @_;
    my %h;
    if(-e $f){
	open IN,'<',$f;
	while(<IN>){
	    chomp;
	    my @l = split/\t/;
	    $h{"$l[0]-$l[1]"} = $l[2];
	}
	return %h;
    }else{
	return %h;
    }
}
