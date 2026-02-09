#! perl

use warnings;
use strict;
use Cwd qw(getcwd abs_path);
use MCE::Loop;
use MLoadData;
use File::Basename;
use Math::Combinatorics;

my $ref = shift;
$ref //= "/home/wenjie/project/z.genome_data/Brachypodium_arbuscula/Barbuscula.genome.fa";
my $query = shift;
$query //= "/home/wenjie/project/Brachypodium_pangenome/0.genome/Brup5/01.assembly/hifiasm_hic/D20a5r5/1.hap1_2_merge/0.hap12.p_ctg.fa";
my $regx = shift;
$regx //= "500k.txt";
my $min_contig = shift;
$min_contig //= 100000;

my $threads_mce = shift;
$threads_mce //= 5;
my $threads_minimap = shift;
$threads_minimap //= 20;

my $query_idx = $query.".fai";
my $ref_idx = $ref.".fai";

if(! -e $query_idx ||! -e $ref_idx){
    print STDERR "USAGE : perl $0 \$ref \$query \$file_rex \$thread_jobs \$thread_minimap2\n\n";
    print STDERR "need samtools index of $ref and/or $query\n";
    exit;
}

my $h_dir = getcwd();
my @fs = sort{$a cmp $b} grep{/$regx/} `ls ./`;

if(scalar @fs < 1){
    print STDERR "USAGE : perl $0 \$ref \$query \$file_rex \$thread_jobs \$thread_minimap2\n\n";
    print STDERR "no file dectected in current directory\n";
    exit;
}

my %contig_len = MLoadData::load_from_file_hash_content($query_idx,"\t",0,1);
#my %ref_len = MLoadData::load_from_file_hash_content($ref_idx,"\t",0,1);

MCE::Loop::init {max_workers => $threads_mce, chunk_size => 1};
mce_loop {&run($_)} @fs;

sub run{
    my $f = shift @_;
    chomp $f;
    my @fc = MLoadData::load_from_file($f);
    (my $n = basename $f) =~ s/\.txt//;
    (my $chr = basename $f) =~ s/\..*//;
    mkdir $n if ! -e $n;
    for(my $i = 0;$i < @fc; $i ++){
        my @l = split/\t/,$fc[$i];
        my @c = split/,/,$l[2];
        my @c_new = &file_len(\@c,\%contig_len,$min_contig);
        my $nn = join"-",@c_new;
        #mkdir "$n/$nn" if ! -e "$n/$nn";
	mkdir "$n/$l[0]-$l[1]_$nn" if ! -e "$n/$l[0]-$l[1]_$nn";
        #mkdir "$n/$nn/$l[0]-$l[1]" if ! -e "$n/$nn/$l[0]-$l[1]";
        chdir "$n/$l[0]-$l[1]_$nn";
        `samtools faidx $ref $chr:$l[0]-$l[1] > ref.fa`;
        unlink "query.fa" if -e "query.fa";
        `samtools faidx $query $_ >> query.fa` for @c_new;
        `minimap2 -t $threads_minimap -x asm20 --secondary=no ref.fa query.fa > query2ref.paf`;
	
        my @dr = MLoadData::load_from_file("query2ref.paf");
        my %query_seg = &paf2longest_query(\@dr);
	
	unlink "query.fix.fa" if -e "query.fix.fa";

	for my $contig (@c_new){
	    my @info = @{$query_seg{$contig}};
            my $interval = "$info[0]-$info[1]";
	    if($info[2] eq "+"){
		`samtools faidx $query $contig:$interval > $contig\.fa`;
	    }else{
		`samtools faidx $query $contig:$interval --reverse-complement  > $contig\.fa`;
	    }
	    `cat $contig\.fa >> query.fix.fa`;
        }
	`minimap2 -t $threads_minimap -x asm20 --secondary=no ref.fa query.fix.fa > query2ref.fix.paf`;
	`~/code/plot/plot_pafCoordsDotPlotly_fix_haplotype.R -i query2ref.fix.paf -o query2ref.fix --interactive-plot-off -p 10 -l -s`;
        my @c_com = combine(2,@c_new);
        for my $c_com_ref (@c_com){
            my @c_com_tmp = @{$c_com_ref};
            my $r_seq;
            my $q_seq;
            if($contig_len{$c_com_tmp[0]}> $contig_len{$c_com_tmp[1]}){
                $r_seq = $c_com_tmp[0];
                $q_seq = $c_com_tmp[1];
            }else{
                $r_seq = $c_com_tmp[1];
                $q_seq = $c_com_tmp[0];
            }
            my $out_paf = "$q_seq"."_2_"."$r_seq".".paf";
            $q_seq = $q_seq.".fa";
            $r_seq = $r_seq.".fa";
            `minimap2 -t $threads_minimap -x asm20 --secondary=no $r_seq $q_seq > $out_paf`;
	    `sort -k10,10nr $out_paf | head -1 |cut -f 1,6,10,11 >> res.txt`;
        }
	chdir $h_dir;
    }
    chdir $n;
    my @fs2 = `ls */res.txt |sort -n`;
    open my $oo,'>',"res.total.txt";
    for my $fs2f (@fs2){
	chomp $fs2f;
	my $nn = dirname $fs2f;
	my @fc2 = MLoadData::load_from_file($fs2f);
	print $oo "##\n";
	for(my $ii = 0;$ii < @fc2; $ii ++){
	    print $oo "$nn\t";
	    print $oo "$fc2[$ii]\n";
	}
    }
    close $oo;
    chdir $h_dir;
}

sub paf2longest_query{
    my $ref = shift @_;
    my @d_sub = @{$ref};
    my %h;
    for my $t (@d_sub){
        my @ll  = split/\t/,$t;
        $h{$ll[0]}{$ll[10]} = [$ll[2],$ll[3],$ll[4]];
    }
    my %r;
    for my $k1 (sort {$a cmp $b} keys %h){
        my $k2 = (sort {$b <=> $a} keys %{$h{$k1}})[0];
        $r{$k1} = $h{$k1}{$k2};
    }
    return %r;
}

sub file_len{
    my $ref1 = shift @_;
    my $ref2 = shift @_;
    my $t = shift @_;
    my @arr = @{$ref1};
    my %h = %{$ref2};
    my @res;
    for my $tmp (@arr){
        if ($h{$tmp} > $t){
            push @res, $tmp;
        }
    }
    return @res;
}
