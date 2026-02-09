#! perl

use warnings;
use strict;

my $ref = "/home/wenjie/code/command_creat/command_query.list.txt";
$/ = "//";

my %h;
open IN,'<',$ref or die "$!";
while(<IN>){
    next if /^$/;
    my @l = split/\n/;
    $l[-1] =~ s/\[(.*)\]\/\//$1/;
    my $n = pop @l;
    $h{$n} = join"\n",@l;
}
$/ = "\n";
print join", ",sort {$a cmp $b} keys %h;

print "\n==============================>\n";
while(1){
    chomp(my $in = <STDIN>);
    if(exists $h{$in}){
	print "==============================>\n";
	print $h{$in}."\n";
	print "==============================>\n";
    }else{
	print "wrong methods\n";
    }
}

