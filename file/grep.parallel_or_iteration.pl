#! perl

use warnings;
use strict;

if (scalar @ARGV < 2){
    print STDERR "USAGE : perl $0 rex1,rex2,rex3 \$file \$mode[1|2] \$v[no|yes]\n\n";
    print STDERR "        mode1: grep rex1|grep rex2|...\n";
    print STDERR "        mode2: grep rex1; grep rex2; grep rex3 ...\n";
    exit;
}
my $rex = shift;
my $file = shift;
my $mode = shift;
my $v = shift;
$mode //= 1;
$v //= "no";

my @rexs = split/,/,$rex;

if($mode == 1){
    if($v eq "no"){
	print "grep '$rexs[0]' $file";
	print "|grep '$_'" for @rexs[1..$#rexs];
    }else{
	print "grep -v '$rexs[0]' $file";
	print "|grep -v '$_'" for @rexs[1..$#rexs];
    }
}
if($mode == 2){
    if($v eq "no"){
	print "rm -fr ~/tmp/grep_extend.tmp\n";
	print "grep '$_' $file >> ~/tmp/grep_extend.tmp\n" for @rexs;
    }else{
	print STDERR "please use mode 1\n";
	exit;
    }
}
