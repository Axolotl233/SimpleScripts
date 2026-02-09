#! perl

use warnings;
use strict;
use Getopt::Long;
use MLoadData;
use List::Util qw/sum/;

my ($col1,$col2,$sep,$mode,$help,$anno,$head,$g_min,$interval,$method);
GetOptions(
    'key_col=s' => \$col1,
    'value_col=s' => \$col2,
    'mode=s' => \$mode,
    'separation=s' => \$sep,
    'anno=s' => \$anno,
    'header' => \$head,
    'help' => \$help,
    'min=s' => \$g_min,
    'interval=s' => \$interval,
    'method=s' => \$method
    );

$col1 //=0;
$col2 //=1;
$sep //= "\t";
$anno //= "#";
$mode //= "file";
$method //= "power";
$g_min //= 10000;
$interval //= 10;


if($help){
    &print_help();
    exit;
}

if($mode eq "file"){
    if($ARGV[0]){
        if(! -e $ARGV[0]){
            print STDERR "Check file pls\n\n";
            &print_help();
            exit;
        }
    }else{
        print STDERR "Need file\n\n";
        &print_help();
        exit;
    }
}

my @data;
if($mode eq "pipeline"){
    if($head){
        @data = MLoadData::load_from_stdin_with_head();
        &run($data[0]);
    }else{
        @data = MLoadData::load_from_stdin();
        &run(\@data);
    }
}elsif($mode eq "file"){
    if($head){
        @data = MLoadData::load_from_file_with_head($ARGV[0]);
        &run($data[0]);
    }else{
        @data = MLoadData::load_from_file($ARGV[0]);
        &run(\@data);
    }
}else{
   &print_help();
   exit;
}

sub run{
    my $d = shift @_;
    my @dd = @{$d};
    my %h;
    my $d_max = undef;
    my $d_min = undef;
    D:for my $line (@dd){
        next D unless length $line;
        next D if $line =~ /^$anno/;
        my @l = split/$sep/,$line;
        push @{$h{$l[$col1]}}, $l[$col2];

	$d_max //= $l[$col2];
	$d_min //= $l[$col2];;
	
	$d_max = ($d_max > $l[$col2])?$d_max:$l[$col2];
	$d_min = ($d_min < $l[$col2])?$d_min:$l[$col2];
    }
    my @ref_a = &interval_creater($d_max,$d_min,$g_min,$interval,$method);

    for my $k (sort {$a cmp $b} keys %h){
	my %res_a;
	my @query_a = @{$h{$k}};

	for my $nn (@query_a){
	    E:for(my $i = 0;$i < scalar(@ref_a);$i += 1){
		my @tmp = @{$ref_a[$i]};
		if($nn >= $tmp[0] && $nn < $tmp[1]){
		    push @{$res_a{$i}},$nn;
		    last E;
		}
	    }
	}
	for(my $i = 0;$i < (scalar @ref_a);$i += 1){
	    my @tmp = @{$ref_a[$i]};
	    if(!exists $res_a{$i}){
		push @{$res_a{$i}},0;
	    }
	    my @p = ("$k","\[$tmp[0],$tmp[1]\)",(scalar @{$res_a{$i}}),(sum(@{$res_a{$i}})));
	    print join"\t",@p;
	    print "\n";
	}
    }
	
}

sub interval_creater{
    my $max = shift @_;
    my $d_min = shift @_; 
    my $min = shift @_;
    my $interval = shift @_;
    my $m = shift @_;
    my @res;
    if($m eq "power"){
	die("min threshold can't <= 0 when used power method\n") if ($min <= 0);
#	print $d_min;exit;
	if ($min <= $d_min){
            #shift @res;
            print STDERR "minium threshold sholud set lager than $d_min\n";
	    exit;
        }
	@res = [int($d_min),$min];
      D2:for(my $s = $min;$s < $max;$s = $s * $interval){
	  my $e = $s * $interval;
	  my $jud = ($e > $max)?1:0;
          push @res, [$s,$e];
	  last D2 if $jud == 1;
      }	
    }elsif($m eq "linear"){
	if ($min <= $d_min){
	    shift @res;
	    print STDERR "warning global minium > minium threshold\n";
	}else{
	    @res = [int($d_min),$min];
	}
      D1:for(my $s = $min;$s < $max;$s += $interval){
          
          my $e = $s + $interval;
	  my $jud = ($e > $max)?1:0;
	      
          push @res, [$s,$e];
	  last D1 if $jud == 1;
      }
    }
    return @res;
}

sub print_help{
    print STDERR "USAGE : perl $0 --mode [pipeline|file] --key_col [0] --value_col [1] --separation ['\\t'] --method [power|linear] --min [10000] --interval [10] --anno ['#'] --header\n";
}
