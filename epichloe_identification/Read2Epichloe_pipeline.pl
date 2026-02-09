#! perl

use warnings;
use strict;
use Cwd qw/getcwd abs_path/;
use File::Basename;
use FindBin qw($Bin);

if(scalar @ARGV < 1){
    print STDERR "USEAG : perl $0 config\n";
    exit;
}

my $f_config = shift;
my $h_dir = getcwd();
my %config = &load_config($f_config);
my %fq_input = &get_fastq($config{dir_input});
if(scalar keys %fq_input == 0){
    print STDERR "no input data loaded, please check\n";
    exit;
}

mkdir $config{dir_output} if ! -e $config{dir_output};
my @step = ("1.filter_reads","2.align","3.bam2fastq","4.assembly","5.its_identification","6.gene_recover");
for(my $i = 0; $i < @step;$i ++) {
    mkdir "$config{dir_output}/$step[$i]" if ! -e "$config{dir_output}/$step[$i]";
    `rm -fr $config{dir_output}/$step[$i].run.sh` if -e "$config{dir_output}/$step[$i].run.sh";
}

for my $sample (sort {$a cmp $b} keys %fq_input){

    my @cmd = ();    
    push @cmd, &quailty_control($sample);
    push @cmd, &initial_align($sample);
    push @cmd, &align_to_fastq($sample);
    push @cmd, &re_assemle($sample);
    push @cmd, &its_ident($sample);
    push @cmd, &gene_recover($sample);
        
    for(my $i = 0; $i < @step;$i ++) {
	open my $o,'>>',"$config{dir_output}/$step[$i].run.sh";
	print $o "$cmd[$i]";
	close $o;
    }
}

for(my $i = 0; $i < @step;$i ++) {
    print "sh $config{dir_output}/$step[$i].run.sh\n";
}

sub gene_recover{
    my $ref = shift @_;
    my $fq_dir = "$config{dir_output}/$step[2]";
    my $res_dir = "$config{dir_output}/$step[5]/$ref";

    my $tmp_cmd;
    $tmp_cmd = "mkdir $res_dir;cd $res_dir;";

    if($config{gene_align_path} eq "minimap2"){
	if($config{library_type} eq "paired"){
	    $tmp_cmd .= "$config{gene_align_path} -t $config{threads} $config{align_option} $config{fa_hq_index} $fq_dir/$ref\_mapped_1.paired.fq $fq_dir/$ref\_mapped_2.paired.fq";
	}elsif($config{library_type} eq "single"){
	    $tmp_cmd .= "$config{gene_align_path} -t $config{threads} $config{align_option} $config{fa_hq_index} $fq_dir/$ref\_mapped.fq";
	}
    }elsif($config{align_method} eq "x-mapper"){
        if($config{library_type} eq "paired"){
            $tmp_cmd = "java -Xmx100G -Xms100G -jar $config{gene_align_path} --cache-dir $config{ref_cache_dir} --reference $config{fa_ref} --paired-queries $fq_dir/$ref\_mapped_1.paired.fq $fq_dir/$ref\_mapped_2.paired.fq --out-sam - --num-threads $config{threads}";
        }elsif($config{library_type} eq "single"){
            $tmp_cmd = "java -Xmx100G -Xms100G -jar $config{gene_align_path} --cache-dir $config{ref_cache_dir} --reference $config{fa_ref} --queries $fq_dir/$ref\_mapped.fq --out-sam - --num-threads $config{threads}";
        }
    }else{
        print STDERR "align_method must be x-mapper or minimap2\n";
        exit;
    }

    $tmp_cmd .= " | samtools view -hF 4 - |samtools sort -O bam -\@ $config{threads} -T tmp -o $res_dir/$ref.remap.sort.bam;";
    $tmp_cmd .= "samtools consensus --show-del yes --show-ins no -a -d 1 -o $ref.fa $ref.remap.sort.bam;samtools faidx $ref.fa;";
    $tmp_cmd .= "perl -i -ple 's/\\\*/N/g' $ref.fa;";
    $tmp_cmd .= "gffread -g $ref.fa -x $ref.cds.fa $config{fa_hq_gff};";
    $tmp_cmd .= "perl $config{dir_scripts}/Summary_Cds.pl $ref.cds.fa $ref.cds.count.txt;"; 
    $tmp_cmd .= "cd $h_dir\n";
    return $tmp_cmd;
}

sub its_ident{
    my $ref = shift @_;
    my $res_dir = "$config{dir_output}/$step[4]/$ref";
    my $fa_assembly = "$config{dir_output}/$step[3]/$ref/assembly.fa";
    my $tmp_cmd;

    $tmp_cmd = "mkdir $res_dir;cd $res_dir;";
    $tmp_cmd .= "blastn -db $config{fa_its_index} -evalue 1e-5 -query $fa_assembly -num_threads $config{threads} -out blast.out -max_target_seqs 1 -outfmt 6;";
    $tmp_cmd .= "grep -v 'plant' blast.out| cut -f 1 | sort |uniq > pre_its.seq.lst;samtools faidx $fa_assembly -r pre_its.seq.lst > pre_its.seq.fa;";
    $tmp_cmd .=	"ITSx -i pre_its.seq.fa -o its --detailed_results T --partial 1 --save_regions all;";
    $tmp_cmd .= "cd $h_dir\n";
    return $tmp_cmd;
}
    
sub re_assemle{
    my $ref = shift @_;
    my $fq_dir = "$config{dir_output}/$step[2]";
    my $res_dir = "$config{dir_output}/$step[3]";
    my $tmp_cmd;
    
    if($config{library_type} eq "paired"){
	$tmp_cmd = "metaspades.py $config{assembly_option} -1 $fq_dir/$ref\_mapped_1.paired.fq -2 $fq_dir/$ref\_mapped_2.paired.fq -t $config{threads} -o $res_dir/$ref; ln -s $res_dir/$ref/scaffolds.fasta $res_dir/$ref/assembly.fa\n";
    }elsif($config{library_type} eq "single"){
	$tmp_cmd = "megahit $config{assembly_option} -r $fq_dir/$ref\_mapped.fq -t $config{threads} -o $res_dir/$ref ;ln -s $res_dir/$ref/final.contigs.fa $res_dir/$ref/assembly.fa\n";
	#$tmp_cmd = "spades $config{assembly_option} -s $fq_dir/$ref\_mapped.fq -t $config{threads} -o $res_dir/$ref; ln -s $res_dir/$ref/scaffolds.fasta $res_dir/$ref/assembly.fa\n";
    }
    return $tmp_cmd;
}

sub align_to_fastq{
    my $ref = shift @_;
    my $fq_dir = "$config{dir_output}/$step[0]";
    my $align_dir = "$config{dir_output}/$step[1]";
    my $res_dir = "$config{dir_output}/$step[2]";
    my $tmp_cmd;

    $tmp_cmd = "samtools fastq -F 0 -n $align_dir/$ref.sort.bam > $res_dir/$ref\_mapped.fq;";
    $tmp_cmd .= "awk 'NR % 4 == 1' $res_dir/$ref\_mapped.fq |sort |uniq |perl -ple 's/\@//' > $res_dir/$ref\_mapped.fq.lst;";
    
    if($config{library_type} eq "paired"){
	$tmp_cmd .= "seqkit grep -f $res_dir/$ref\_mapped.fq.lst $fq_dir/$ref\_1.fix.fq.gz > $res_dir/$ref\_mapped_1.paired.fq;";
	$tmp_cmd .= "seqkit grep -f $res_dir/$ref\_mapped.fq.lst $fq_dir/$ref\_2.fix.fq.gz > $res_dir/$ref\_mapped_2.paired.fq\n";
    }elsif($config{library_type} eq "single"){
	$tmp_cmd .= "\n";
    }
    return $tmp_cmd;
}

sub initial_align{
    my $ref = shift @_;
    my $fq_dir = "$config{dir_output}/$step[0]";
    my $align_dir = "$config{dir_output}/$step[1]";
    my $dir_ref = dirname $config{fa_ref};
    my $tmp_cmd;

    if($config{align_method} eq "minimap2"){
	if($config{library_type} eq "paired"){
	    $tmp_cmd = "$config{align_path} -t $config{threads} $config{align_option} $config{fa_ref} $fq_dir/$ref\_1.fix.fq.gz $fq_dir/$ref\_2.fix.fq.gz";
	}elsif($config{library_type} eq "single"){
	    $tmp_cmd = "$config{align_path} -t $config{threads} $config{align_option} $config{fa_ref} $fq_dir/$ref.fix.fq.gz";
	}
    }elsif($config{align_method} eq "x-mapper"){
	if($config{library_type} eq "paired"){
            $tmp_cmd = "java -Xmx100G -Xms100G -jar $config{align_path} $config{align_option} --cache-dir $dir_ref --reference $config{fa_ref} --paired-queries $fq_dir/$ref\_1.fix.fq.gz $fq_dir/$ref\_2.fix.fq.gz --out-sam - --num-threads $config{threads}";
        }elsif($config{library_type} eq "single"){
	    $tmp_cmd = "java -Xmx100G -Xms100G -jar $config{align_path} $config{align_option} --cache-dir $dir_ref --reference $config{fa_ref} --queries $fq_dir/$ref.fix.fq.gz --out-sam - --num-threads $config{threads}";
        }
    }else{
	print STDERR "align_method must be x-mapper or minimap2\n";
	exit;
    }
    $tmp_cmd .= " | samtools view -hF 260 - |samtools sort -O bam -\@ $config{threads} -T tmp -o $align_dir/$ref.sort.bam\n";
    return $tmp_cmd;
}

sub quailty_control{
    my $ref = shift @_;
    my @fqs = @{$fq_input{$ref}};
    my $tmp_cmd;
    if($config{library_type} eq "paired"){
	$tmp_cmd = "cd $config{dir_output}/$step[0]; fastp -w 10 -5 -3 -n 0 --length_required 75 -q 20 -i $fqs[0] -I $fqs[1] -o $ref\_1.fix.fq.gz -O $ref\_2.fix.fq.gz;cd $h_dir\n";
    }elsif($config{library_type} eq "single"){
	$tmp_cmd = "cd $config{dir_output}/$step[0]; fastp -w 10 -5 -3 -n 0 --length_required 75 -q 20 -i $fqs[0] -o $ref.fix.fq.gz ;cd $h_dir\n";
    }	
    return $tmp_cmd;
}

sub get_single_fastq{
    my $d = shift @_;
    my %h;
    my @fq = sort{$a cmp $b} grep {/(fq|fastq)\.?(gz)?$/} `find $d`;
    for my $f(@fq){
        chomp $f;
        (my $f_n = basename $f) =~ s/(\_|\.)(fq|fastq)\.?(gz)?$//;
	if(exists $h{$f_n}){
	    print STDERR "wrong reads information $f_n:$f\n";
	    exit;
	}
	push @{$h{$f_n}}, $f;
    }
    return %h;

}

sub get_fastq{
    my $d = shift @_;
    my %h;
    if($config{library_type} eq "paired"){
	my @fq1s = sort{$a cmp $b} grep {/(_|.)1(.|_)(fq|fastq)\.?(gz)?$/} `find $d`;
	for my $f1(@fq1s){
	    chomp $f1;
	    $f1 =~ /(_|.)1(.|_)(fq|fastq)\.?(gz)?/;
	    my $f1_n = basename $f1;
	    my @sep = ($1,$2,$3,(defined $4)?$4:"");
	    my @base = (1,2);
	    (my $f2_n = $f1_n) =~ s/$sep[0]$base[0]$sep[1]$sep[2]/$sep[0]$base[1]$sep[1]$sep[2]/;
	    (my $name = $f1_n) =~ s/$sep[0]$base[0]$sep[1]$sep[2]//;
	    my $f2 = "$d/$f2_n";
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
    }elsif($config{library_type} eq "single"){
	my @fq = sort{$a cmp $b} grep {/(fq|fastq)\.?(gz)?$/} `find $d`;
	for my $f(@fq){
	    chomp $f;
	    (my $f_n = basename $f) =~ s/(\_|\.)(fq|fastq)\.?(gz)?$//;
	    if(exists $h{$f_n}){
		print STDERR "wrong reads information $f_n:$f\n";
		exit;
	    }
	    push @{$h{$f_n}}, $f;
	}
    }
    return %h;
}

sub load_config{
    my $f = shift @_;
    my %h;
    open IN,'<',$f or die "$!";
    while(<IN>){
	chomp;
	next if /^#/;
	next unless length;
	s/\s+\=\s+/=/;
	my @l = split/=/;
	$h{$l[0]} = $l[1];
    }
    close IN;
    if(! defined $h{align_method}) {
	print STDERR "please provide a align_method in config";
	exit;
    }
    if(! defined $h{align_path}){
	print STDERR "please provide a path of align software in config";
        exit;
    }
    if(! defined $h{dir_input}){
	print STDERR "please provide a path of input data directory in config";
        exit;
    }
    if(! defined $h{fa_ref}){
	print STDERR "please provide a path of reference genome in config";
	exit;
    }
    if(! defined $h{fa_its_index}){
        print STDERR "please provide a path of ist blast index in config";
        exit;
    }
    if(! defined $h{library_type}){
	print STDERR "please provide reads library type (single|paired)";
	exit;
    }
    if(! defined $h{fa_hq_ref}){
        print STDERR "please provide a path of reference genome for annotation in config";
        exit;
    }
    if(! defined $h{fa_hq_index}){
        print STDERR "please provide a path of reference genome index for annotation in config";
        exit;
    }
    if(! defined $h{fa_hq_gff}){
        print STDERR "please provide a path of gff of reference genome";
        exit;
    }

    $h{align_option} = defined $h{align_option} ? $h{align_option}:"";
    $h{dir_output} = defined $h{dir_output} ? $h{dir_output}:"output";
    $h{threads} = defined $h{threads} ? $h{threads}: 30;
    $h{assembly_method} = defined $h{assembly_method}? $h{assembly_method}: "metaspades";
    $h{assembly_option} = defined $h{assembly_option}? $h{assembly_option}: "";
    $h{dir_scripts} =  defined $h{dir_scripts}? $h{dir_scripts}:"$Bin/Skimming2Epichloe.util";
    
    unless($h{library_type} eq "paired" || $h{library_type} eq "single"){
	print STDERR "library_type must be paired or single\n";
	exit;
    }
       
    $h{dir_output} = abs_path($h{dir_output});
    $h{dir_input} = abs_path($h{dir_input});
    $h{dir_scripts} = abs_path($h{dir_scripts});
    #$h{fa_ref} = abs_path($h{fa_ref});
    #$h{fa_its_index} = abs_path($h{fa_its_index});
   
    return %h
}
