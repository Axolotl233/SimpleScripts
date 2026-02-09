package MLoadSeqInfo;

use strict;
use warnings;
use File::Basename;
use Cwd qw/abs_path/;

sub load_paired_fastq{
    my $dir = shift @_;
    my %h;
    $dir = abs_path($dir);
    my @fq1s = sort{$a cmp $b} grep {/(_|.)1(.|_)(fq|fastq)\.?(gz)?$/} `find $dir`;
    for my $f1(@fq1s){
	chomp $f1;
	$f1 =~ /(_|.)1(.|_)(fq|fastq)\.?(gz)?/;
	my $f1_n = basename $f1;
	my @sep = ($1,$2,$3,(defined $4)?$4:"");
	my @base = (1,2);
	(my $f2_n = $f1_n) =~ s/$sep[0]$base[0]$sep[1]$sep[2]/$sep[0]$base[1]$sep[1]$sep[2]/;
	(my $name = $f1_n) =~ s/$sep[0]$base[0]$sep[1]$sep[2]//;
	my $f2 = "$dir/$f2_n";
	if(! -e $f2){
	    print STDERR "please check if exist files:\n$f1\n$f2\n";
                exit;
	}
        $name =~ s/\.$sep[3]// if $sep[3] ne "";
	if(exists $h{$name}){
	    print STDERR "wrong reads information $name:$f1\n";
	    exit;
	}
	$h{$name} = [$f1,$f2];
    }
    return %h;
}
sub load_single_fastq{
    my $dir = shift @_;
    my %h;
    $dir = abs_path($dir);
    my @fqs = sort{$a cmp $b} grep {/(fq|fastq)\.?(gz)?$/} `find $dir`;
    for my $fq(@fqs){
	chomp $fq;
	(my $name = basename $fq) =~ s/\.(fq|fastq).*//;
	$h{$name} = $fq;
    }
    return %h;
}
sub load_single_fasta{
    my $dir = shift @_;
    my %h;
    $dir = abs_path($dir);
    my @fas = sort{$a cmp $b} grep {/(fa|fasta)/} `find $dir`;
    for my $fa(@fas){
        chomp $fa;
        (my $name = basename $fa) =~ s/\.(fa|fasta)//;
        $h{$name} = $fa;
    }
    return %h;
}

sub hello {
    print "Hello, World!\n";
}

1;
