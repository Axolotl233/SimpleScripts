#! perl

use warnings;
use strict;
use Cwd;

my $dir = getcwd();
my $num = int(rand(2000 - 1000 + 1)) + 1000;

if(scalar @ARGV < 1){
    print STDERR "USAGE : perl $0 \$fq1[.gz] .. \$fqn[.gz]\n";
    exit;
}

for my $f (@ARGV){
    if($f =~ /\.gz/){
	print "pigz -dc $f >> used.$num.fq\n";
    }else{
	print "cat $f >> used.$num.fq\n";
    }
}
print "FastK -v -t4 -k31 -M16 -T40 $dir/used.$num.fq -N$dir/FastK_Table\n";
print "smudgeplot hetmers -L 12 -t 20 -o kmerpairs --verbose FastK_Table\n";
print "smudgeplot all -o smudgeplot kmerpairs.smu -cov_min 0 -cov_max 200\n";
print "Histex -h1:10000 -G FastK_Table > FastK.hist\n";
print "genomescope.R -i FastK.hist -o ./ -p 2 -k 31\n";
print "rm -fr used.$num.fq\n";
