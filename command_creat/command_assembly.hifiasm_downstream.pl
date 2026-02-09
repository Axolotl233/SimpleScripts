#! perl

use warnings;
use strict;
use Cwd qw/abs_path getcwd/;
use File::Basename;

my $prefix = shift;
$prefix //= "genome";
my $h_dir = getcwd();

my @fs = grep {/gfa/} `find ./`;
for my $f (@fs){
    chomp $f;
    $f = abs_path $f;
    next unless $f =~ (/[par]_[cu]tg.gfa/);
    (my $p = basename $f) =~ s/\.gfa//;
    next if -e "$p.fa";
    print "gfatools gfa2fa $f > $p.fa;";
    print "mkdir $p;cd $p;ln -s $h_dir/$p.fa ./;cd $h_dir\n";
}
print "perl ~/code/gfa/gfa_convert.ctg_utg.pl genome.hic.p_utg.gfa genome.hic.p_ctg.gfa\n";
#print "#winnowmap -W ~/database/genome_data/Brachypodium_arbuscula/JGI_31/Barbuscula.repetitive_k19.txt --secondary=no -x asm20 ~/database/genome_data/Brachypodium_arbuscula/JGI_31/Barbuscula.genome.fa ./genome.fa > output.paf"
