#! perl

use warnings;
use strict;

while(<>){
    my @l1= split/;/;
    my @l2 = split/\s+/,$l1[1];
    next if -e "z.split/$l2[3].masked";
    print $_;
}
