#! perl

use warnings;
use strict;

my $n = shift;
if($n == 0){
    print "ls |perl -nle '(my \$c = \$_) =~ s///; print \" \"'\n";
}
