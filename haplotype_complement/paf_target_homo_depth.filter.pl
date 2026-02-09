#! perl

use warnings;
use strict;
use MLoadData;
use MCE::Loop;
use File::Basename;
use Getopt::Long;
use Cwd qw(abs_path getcwd);
use List::Util qw/uniq/;
 
my $dir = shift;
my $depth = shift;
my $mode = shift;
$mode //= "less";
my $min_len = shift;
$min_len //= 10000;
my $thread = shift;
$thread //= 1;

if(! $dir || !$depth){
    print "USAGE : perl $0 \$dir \$homodepth \$mode[less|more] \$min_len[10000] \$thread[1] ";
    print "(\$dir is the result from paf_target_homo_depth.pl)\n";
    exit;
}

$dir = abs_path($dir);
my $h_dir = getcwd();
my @fs = grep {/.homo_depth.txt/} `ls $dir`;

MCE::Loop::init {max_workers => $thread, chunk_size => 1};
mce_loop {&run($_)} @fs;

my @fs2 = grep {/homo_depth.filter.$mode.$depth.txt/} `ls $dir`;
for my $f2 (@fs2){
    chomp $f2;
    (my $n2 = basename $f2) =~ s/\..*//;
    open IN,'<',"$dir/$f2" or die "$!";
    while(<IN>){
	next if /^#/;
	print "$n2\t$_";
    }
    close IN;
}

sub run{
    my $f = shift @_;
    chomp $f;
    (my $n = basename $f) =~ s/\..*//;
    my @f_c = MLoadData::load_from_file("$dir/$f");
    my ($max,$min) = (undef,undef);
    my @p;
    open my $ofh,'>',"$dir/$n.homo_depth.filter.$mode.$depth.txt";
    for(my $i = 0;$i < @f_c;$i += 1){
	if($f_c[$i] =~ /^#/){
	    for my $t_ref (@p){
		my @t_p = @{$t_ref};
		my $rate = ($t_p[1] - $t_p[0] + 1)/($max-$min+1);
		print $ofh "$t_p[0]\t$t_p[1]\t$t_p[2]\t$rate\n";
		print $ofh "#\n";
	    }
	    ($max,$min) = (undef,undef);
	    @p = ();
	}else{
	    #print $f_c[$i];exit;
	    my @l = split/\t/,$f_c[$i];
	    my @ctgs = split/,/,$l[2];
	    my @ctgs_uniq = uniq(@ctgs);
	    $l[2] = join",", @ctgs_uniq;
	    my @num = @ctgs_uniq;
	    #my @num = split/,/,$l[2];
	    #my @tmp_1 = split/,/,$l[2];
	    #my %tmp_2;
	    #$tmp_2{$_} = 1 for @tmp_1;
	    #my @num = sort{$a cmp $b} keys %tmp_2;
	    $min //= $l[0];
	    $max //= $l[1];
	    $min = ($min < $l[0])? $min:$l[0];
	    $max = ($max > $l[1])? $max:$l[1];
	    if ($mode eq "less"){
		if(scalar @num < $depth){
		    if($l[1] - $l[0] > $min_len){
			push @p, [$l[0],$l[1],$l[2]];
		    }
		}
	    }
	    if ($mode eq "more"){
		if(scalar @num > $depth){
                    if($l[1] - $l[0] > $min_len){
                        push @p, [$l[0],$l[1],$l[2]];
                    }
                }
	    }
	    
	}
    }
    close $ofh;
}
