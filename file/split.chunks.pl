#! perl

use warnings;
use strict;
use File::Basename;

my $file = shift;
my $s_num = shift;
die "'split_num' must is a numeber " unless ($s_num =~ /\d+/);

my $line_num = `wc -l $file`;
$line_num =~ s/\s.*//;
my $re = $line_num % $s_num;
my $part_line = ($line_num - $re) / $s_num;
my @part;
for(my $i = 0;$i < $s_num;$i += 1){
    my $tmp = $part_line;
    if($re > 0){
        $tmp += 1;
        $re -= 1;
        push @part,$tmp;
    }else{
        push @part,$tmp;
    }
}

chomp $file;
open IN,'<',$file or die "$!";
(my $name = basename $file) =~ s/(.*)\..*/$1/;
my $c = 0;
for my $e (@part){
    $c += 1;
    open O,'>',"$name.split.$c.sh";
    for(my $i = 0; $i< $e;$i += 1){
        my $p = readline IN;
        print O $p;
    }
    close O;
}
close IN;
