#! perl

use Cwd qw(getcwd abs_path);
use strict;
use warnings;

if(@ARGV < 2){
    print STDERR "USAGE: perl $0 \$compare \$dir [\$config_wgdi]\n";
    exit;
}

my $compare = shift;
my $dir = shift;
$dir = abs_path($dir);

my $config = shift;
$config //= "/home/wenjie/code/wgdi/wgdi.total.conf";

my @sps;
open IN,'<',$compare;
while(<IN>){
    chomp;
    my @l = split/\t/;
    push @sps, "$l[0]-$l[1]";
}

for my $sps (@sps){
    open (SH,">z.$sps.run.sh");
    #`rm -r $sps` if (-e "$sps");
    `mkdir $sps` if (! -e "$sps");
    $sps=~/^(\w+)-(\w+)$/ or die "$sps";
    my ($sp1,$sp2)=($1,$2);
    if ($sp1 eq $sp2){
        `cd $sps ; ln -s $dir/$sp1.wgdi.* . ;  cd ../` if (! -e "$sps/$sp1.wgdi.gff");
        `cd $sps ; ln -s $sp1.wgdi.cds All.cds ; cd ../` if (! -e "$sps/All.cds");
        `cd $sps ; ln -s $sp1.wgdi.pep All.pep ; cd ../` if (! -e "$sps/All.pep");
    }else{
        `cd $sps ; ln -s $dir/$sp1.wgdi.* . ;  cd ../` if (! -e "$sps/$sp1.wgdi.gff");
        `cd $sps ; ln -s $dir/$sp2.wgdi.* . ;  cd ../` if (! -e "$sps/$sp2.wgdi.gff");
        `cd $sps ; cat $sp1.wgdi.cds $sp2.wgdi.cds > All.cds ; cd ../` if (! -e "$sps/All.cds");
        `cd $sps ; cat $sp1.wgdi.pep $sp2.wgdi.pep > All.pep ; cd ../` if (! -e "$sps/All.pep");
    }
    open (O,">$sps/total.conf")||die"$!";
    open (F,"$config")||die"$!";
    while (<F>){
        s/sp1/$sp1/;
        s/sp2/$sp2/;
        print O "$_";
    }
    close F;
    close O;
    die "please check /home/wenjie/code/command_creat/command_blast.diamond_blastp.pl" if !-e "/home/wenjie/code/command_creat/command_blast.diamond_blastp.pl";
    print SH "cd $sps;
perl /home/wenjie/code/command_creat/command_blast.diamond_blastp.pl All.pep All.pep 200 | sh;
wgdi -icl total.conf > collinearity.log 2>&1
wgdi -ks total.conf > ks.log 2>&1;
wgdi -bi total.conf > blockinfo.log 2>&1
wgdi -c total.conf > correspondence.log 2>&1
wgdi -bk total.conf > blockks.log 2>&1
wgdi -km total.conf > karyotype_mapping.log 2>&1
wgdi -k total.conf > karyotype.log 2>&1
wgdi -pc total.conf > classification.log 2>&1
wgdi -a total.conf > alignment.log 2>&1
wgdi -d total.conf > dotplot.log 2>&1
cd ../;\n";
    close SH;
}
