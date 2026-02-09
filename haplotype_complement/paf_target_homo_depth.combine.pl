#! perl

use warnings;
use strict;
use MLoadData;
use File::Basename;
use Cwd;
use List::Util qw(uniq);

my $h_dir = getcwd();
my $d_dir = shift;
my $reg = shift;
$reg //= "more.3";
my $ex_bp = shift;
$ex_bp //= 500000;
my $n_ex = $ex_bp/1000;
$n_ex = $n_ex."k";

my @fs = grep {/homo_depth.filter.$reg.txt/} `ls $d_dir`;
for my $f (@fs){
    chomp $f;
    (my $n = $f) =~ s/\.txt//;
    my ($last_s,$last_e,$last_c) = (undef,undef,undef);
    my @c;
    open O,'>',"$d_dir/$n.combine.$n_ex.txt";
    open O2,'>',"$d_dir/$n.combine.$n_ex.contig.lst";
    my @fc = MLoadData::load_from_file("$d_dir/$f");
    D: for(my $i = 0; $i < @fc; $i++){
	next D if $fc[$i] =~ /#/;
	my @l = split/\t/,$fc[$i];
	my @tt = split/,/,$l[2];
	@c = (@c, @tt);
	if(! $last_s){
	    $last_s = $l[0];
	    $last_e = $l[1];
	    $last_c = $l[2];
	    next;
	}
	my $s = $l[0] - $ex_bp;
	my $e = $l[1];

	if($s < $last_e && $e > $last_s && $last_c eq $l[2]){
	    $last_e = $e;
	}else{
	    print O "$last_s\t$last_e\t$last_c\n";
	    $last_s = $l[0];
	    $last_e = $l[1];
	    $last_c = $l[2];
	}
    }
    @c = sort {$a cmp $b} uniq(@c);
    print O "$last_s\t$last_e\t$last_c\n";
    close O;
    print O2 join"\n",@c;
    print O2 "\n";
    close O2;
}
