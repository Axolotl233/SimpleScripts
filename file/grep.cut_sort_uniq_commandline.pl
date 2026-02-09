#! perl

use warnings;
use strict;

if (scalar @ARGV < 1){
    print STDERR "USAGE : perl $0 \$f \$grep_opt \$cut_opt \$sort_opt \$uniq_opt\n\n";
    print STDERR "        default : grep \$f | cut -f 1|sort |uniq -c \n";
    exit;
}

my $f = shift;
my $grep_opt = shift;
my $cut_opt = shift;
my $sort_opt = shift;
my $uniq_opt = shift;

$grep_opt //= "";
$cut_opt //= "-f 1";
$sort_opt //= "";
$uniq_opt //= "-c";

print "grep $grep_opt $f|cut $cut_opt |sort $sort_opt|uniq $uniq_opt";
