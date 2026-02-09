#! perl

use strict;
use warnings;
use Cwd qw/abs_path getcwd/;
use File::Basename;
use FindBin qw($Bin);

if(scalar @ARGV != 1){
    &print_help;
    exit;
}

my $base_dir = getcwd();
my $config_file = shift;
my %config = &load_config($config_file);

mkdir "$config{output}" if ! -e "$config{output}";
my @step = ("0.split","1.denovo","2.repeatmasker-database","3.repeatproteinmask","4.trf","5.merge");
for(my $i = 0; $i < @step;$i ++) {
    mkdir "$config{output}/$step[$i]" if ! -e "$config{output}/$step[$i]";
    `rm -fr $config{output}/$step[$i].run.sh` if -e "$config{output}/$step[$i].run.sh";
}

### SplitGenome
open O0,'>',"$config{output}/$step[0].run.sh";
print O0 "perl $config{script}/split_fasta.pl $config{genome} $config{output}/$step[0] no\n";
close O0;
my @fs = sort{$a cmp $b} grep {/\.fa$/} `ls $config{output}/$step[0]`;
if(scalar @fs == 0){
    `sh $config{output}/$step[0].run.sh`;
    @fs = sort{$a cmp $b} grep {/\.fa$/} `ls $config{output}/$step[0]`;
}
chomp $_ for @fs;

### Denovo-RepeatModeler
my $tmp_dir1 = "$config{output}/$step[1]/1.repeatmodeler";
mkdir $tmp_dir1 if !-e $tmp_dir1;

open O1T1,'>',"$tmp_dir1/0.run.sh";
print O1T1 "cd $tmp_dir1;ln -s $config{genome} genome.fa
$config{BuildDatabase} -name genome genome.fa
$config{RepeatModeler} -threads $config{threads} -database genome -numAddlRounds 6 -LTRStruct
$config{RepeatMasker} -pa $config{parallel_jobs} -lib ./genome-families.fa genome.fa
perl $config{script}/ConvertFormat_Repeat2gff.pl genome.fa.out Denovo.gff Denovo
cd $base_dir\n";
close O1T1;

### Denovo-LTR_Retriever
my $tmp_dir2 = "$config{output}/$step[1]/2.ltr_retriever";
mkdir $tmp_dir2 if !-e $tmp_dir2;
open O1T2,'>',"$tmp_dir2/0.run.sh";
print O1T2 "cd $tmp_dir2;mkdir -p 01.LTRfinder 02.LTRHarvest 03.LTR_retriever
cd 01.LTRfinder;ln -s $config{genome} genome.fa; $config{ltr_finder} -seq genome.fa -threads $config{threads} -harvest_out -size 5000000 -time 3000;cd $tmp_dir2
cd 02.LTRHarvest;ln -s $config{genome} genome.fa; gt suffixerator -db genome.fa -indexname genome.fa -tis -suf -lcp -des -ssp -sds -dna;gt ltrharvest -index genome.fa -minlenltr 100 -maxlenltr 7000 -mintsd 4 -maxtsd 6 -motif TGCA -motifmis 1 -similar 85 -vic 10 -seed 20 -seqids yes > genome.fa.harvest.scn;cd $tmp_dir2
cd 03.LTR_retriever;ln -s $config{genome} genome.fa;cat $tmp_dir2/02.LTRHarvest/genome.fa.harvest.scn $tmp_dir2/01.LTRfinder/genome.fa.finder.combine.scn > genome.fa.rawLTR.scn;LTR_retriever -genome genome.fa -inharvest genome.fa.rawLTR.scn -threads $config{threads};cd $tmp_dir2
cd $base_dir\n";
close O1T2;

### Denovo-merge
my $tmp_dir3 = "$config{output}/$step[1]/z.merge_lib";
mkdir $tmp_dir3 if !-e $tmp_dir3;
open O1Tz,'>',"$tmp_dir3/0.run.sh";
print O1Tz "cd $tmp_dir3;ln -s $config{genome} genome.fa
ln -s $tmp_dir1/genome-families.fa RepeatModeler.fa
ln -s $tmp_dir2/03.LTR_retriever/genome.fa.LTRlib.redundant.fa LTR_retriever.fa
cat RepeatModeler.fa LTR_retriever.fa > custom.lib.fa
$config{RepeatMasker} -pa $config{parallel_jobs} -lib ./custom.lib.fa genome.fa
perl $config{script}/ConvertFormat_Repeat2gff.pl genome.fa.out Denovo_merge.gff Denovo
cd $base_dir\n";

open O1,'>',"$config{output}/$step[1].run.sh";
print O1 "sh $tmp_dir1/0.run.sh
sh $tmp_dir2/0.run.sh
sh $tmp_dir3/0.run.sh\n";
close O1;

### RepeatMasker
open O2,'>',"$config{output}/$step[2].run.sh";
print O2 "cd $config{output}/$step[2];ln -s $config{genome} genome.fa
$config{RepeatMasker} -pa $config{parallel_jobs} -nolow -norna -no_is -gff -species $config{repeat_species} genome.fa
perl $config{script}/ConvertFormat_Repeat2gff.pl genome.fa.out TE.gff TE
cd $base_dir";
close O2;

### RepeatProteinMask
open O3T,'>',"$config{output}/$step[3]/z.split_run.sh";
my $split_dir_rpp = "$config{output}/$step[3]/z.split";
mkdir $split_dir_rpp if !-e $split_dir_rpp; 
for my $f (@fs){
    my $f_abs = "$config{output}/$step[0]/$f";
    print O3T "cd $split_dir_rpp;ln -s $f_abs $f;$config{RepeatProteinMask} -noLowSimple -pvalue 1e-04 $f;cd $config{output}/$step[3]\n";
}
close O3T;
open O3,'>',"$config{output}/$step[3].run.sh";
print O3 "cd $config{output}/$step[3]
parallel -j $config{parallel_jobs} < z.split_run.sh
cat $split_dir_rpp/*annot > genome.repeatproteinmasker.annot
perl $config{script}/ConvertFormat_Repeat2gff.pl genome.repeatproteinmasker.annot TP.gff TP
cd $base_dir\n";
close O3;

### TRF
open O4T,'>',"$config{output}/$step[4]/z.split_run.sh";
my $split_dir_trf = "$config{output}/$step[4]/z.split";
mkdir $split_dir_trf if ! -e $split_dir_trf;
for my $f (@fs){
    my $f_abs = "$config{output}/$step[0]/$f";
    print O4T "cd $split_dir_trf;ln -s $f_abs $f;$config{trf} $f 2 7 7 80 10 50 2000 -d -h;cd $config{output}/$step[4]\n";
}
close O4T;
open O4,'>',"$config{output}/$step[4].run.sh";
print O4 "cd $config{output}/$step[4];
parallel -j $config{parallel_jobs} < z.split_run.sh
cat $split_dir_trf/*dat > genome.fa.trf.dat 
perl $config{script}/ConvertFormat_Trf2Gff.pl genome.fa.trf.dat genome.trf.gff
cd $base_dir\n";
close O4;

open O5,'>',"$config{output}/$step[5].run.sh";
print O5 "cd $config{output}/$step[5];
ln -s $config{genome} genome.fa
ln -s $config{output}/$step[1]/z.merge_lib/Denovo_merge.gff Denovo.gff
ln -s $config{output}/$step[2]/TE.gff TE.gff
ln -s $config{output}/$step[3]/TP.gff TP.gff
ln -s $config{output}/$step[4]/genome.trf.gff TRF.gff
cat Denovo.gff TE.gff TP.gff TRF.gff | grep -v -P '^#' | cut -f 1,4,5 | sort -k1,1 -k2,2n -k3,3n > All.repeat.bed
bedtools merge -i All.repeat.bed > All.repeat.merge.bed
bedtools maskfasta -fi genome.fa -bed All.repeat.merge.bed -fo genome.fa.mask\n";

sub load_config {
    my %h;
    my $f = shift @_;
    open IN,'<',"$f" or die "no such file: $f\n";
    while (<IN>) {
        chomp;
        next if /^#/;
        next if /^\s*$/;
        $_=~ /^(\S+)\s*?=\s*?([^#\s]+)\s*?#*?.*/;
        $h{$1}=$2;
    }
    close IN;
    if(!defined $h{genome}){
        print STDERR "please provide a path of genome in $f\n";
        exit;
    }

    $h{trf} = defined $h{trf} ? $h{trf}:"trf";
    $h{output} = defined $h{output} ? $h{output}:"repeat_identification";
    $h{threads} = defined $h{threads} ? $h{threads}: 30;
    $h{parallel_jobs} = defined $h{parallel_jobs} ? $h{parallel_jobs} : 10;
    $h{BuildDatabase} = defined $h{BuildDatabase}? $h{BuildDatabase}: "BuildDatabase";
    $h{RepeatModeler} = defined $h{RepeatModeler}? $h{RepeatModeler}: "RepeatModeler";
    $h{RepeatMasker} = defined $h{RepeatMasker}? $h{RepeatMasker}: "RepeatMasker";
    $h{RepeatProteinMask} = defined $h{RepeatProteinMask}? $h{RepeatProteinMask}: "RepeatProteinMask";
    $h{repeat_species} = defined $h{repeat_species}? $h{repeat_species}: "Mesangiospermae";
    $h{script} =  defined $h{script}? $h{script}:"$Bin/utils";

    $h{output} = abs_path($h{output});
    return %h;
}

sub print_help{
    print STDERR "Usage: perl $0 \$repeat.anno.config\n";
}

