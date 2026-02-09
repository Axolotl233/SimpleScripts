#! perl

use warnings;
use strict;
use Cwd qw/getcwd abs_path/;

my $h_dir = getcwd();
my @ds = grep{/chain/} grep{!/lst/} `ls`;

if(scalar @ds == 0){
    print STDERR "0 input\n";
    exit;
}

open O1,'>',"0.concentrate.tree.sh";
open O2,'>',"0.astral.tree.sh";
for my $d(@ds){
    chomp $d;
#    print $d;exit;
    print O1 "cd $d;perl /home/wenjie/code/tree/1.align.pl split_gene > 1.align.sh;parallel -j 8 < 1.align.sh;perl /home/wenjie/code/tree/2.concentrate.pl > 2.concentrate.fa;iqtree2 -s 2.concentrate.fa -m MFP -bb 1000 -nt 30;cd $h_dir\n";
    print O2 "cd $d;perl /home/wenjie/code/tree/3.gene_tree.pl split_gene > 3.tree.sh;parallel -j 8 < 3.tree.sh;cat split_gene/*/cds.muscle.fa.treefile > 3.all.tree;~/software/ASTER/bin/astral4 -u 3 3.all.tree > 3.all.astral4.tree;cd $h_dir\n";
}
