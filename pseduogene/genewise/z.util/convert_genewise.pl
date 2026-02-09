#! perl

use strict;
use warnings;
#use File;
use Cwd;

my $h_dir = getcwd();
my @dir = split/\//,$h_dir;
my $id = "$dir[-3]\_$dir[-2]\_$dir[-1]";
open I,'<',"genewise.out";
$/="//";

my @lines=<I>;
pop @lines;
#print $#lines;exit;
my $c = 1;
open O,'>',"genewise.pep";
open O2,'>',"genewise.pseudo.pep";
for(my $i = 1;$i < $#lines;$i += 4){
    my @pep=split(/\n/,$lines[$i]);
    D:foreach my $line(@pep){
	next if($line=~/^\s*$/);
	next if($line=~/^\/\//);
	chomp $line;
	if($line=~/^>/){
	    $line=">$id\_$c";
	}
	if($line=~/pseudo gene/){
	    print O2 "#$id\_$c\n";
	    next D;
	}
	print O "$line\n";
    }
    $c += 1;
}
close O;
$c = 1;
open O,'>',"genewise.cds";
for(my $i = 2;$i < $#lines;$i += 4){
    my @cds=split(/\n/,$lines[$i]);
    foreach my $line(@cds){
        next if($line=~/^\s*$/);
        next if($line=~/^\/\//);
        chomp $line;
        if($line=~/^>/){
            $line=">$id\_$c";
        }
        print O "$line\n";
    }
    $c += 1;
}
close O;
$c = 1;
open O,'>',"genewise.gff";
for(my $i = 3;$i <= $#lines;$i += 4){
    my @gff=split(/\n/,$lines[$i]);
    foreach my $line(@gff){
	next if($line=~/^\s*$/);
	next if($line=~/^\/\//);
	chomp $line;
	# print O "$line\n";
	my @a=split(/\s+/,$line);
	next if($a[2]=~/intron/);
	my $start_location=1;
	if($a[0]=~/^(\S+):(\d+)-\d+/){
	    $a[0]=$1;
	    $start_location=$2;
	}
	$a[8]="ID=$id\_$c;Parent=$id\_$c;";
	if($a[3]>$a[4]){
	    my $tmp=$a[3];
	    $a[3]=$a[4];
	    $a[4]=$tmp;
	}
	$a[3]=$a[3]+$start_location-1;
	$a[4]=$a[4]+$start_location-1;
	if($a[2]=~/match/){
	    $a[2]="gene";
	    my $line1=join "\t",@a;
	    print O "$line1\n";
	    $a[2]="mRNA";
	    my $line2=join "\t",@a;
	    print O "$line2\n";
	}
	else {
	    $a[2]="CDS";
	    my $line1=join "\t",@a;
	    print O "$line1\n";
	}
    }
    $c += 1;
}
close O;

$/="\n";
close I;
