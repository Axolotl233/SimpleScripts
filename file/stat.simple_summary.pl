#! perl

use warnings;
use strict;
#use List::Util qw(sum max min);
use Getopt::Long;
use Statistics::Descriptive;
use MLoadData;

my ($col1,$col2,$sep,$mode,$help,$anno,$method,$head,$digi);
GetOptions(
    'key_col=s' => \$col1,
    'value_col=s' => \$col2,
    'mode=s' => \$mode,
    'separation=s' => \$sep,
    'method=s' => \$method,
    'anno=s' => \$anno,
    'header' => \$head,
    'help' => \$help,
#    'round=s' => $digi,
    );

$col1 //=0;
$col2 //=1;
$sep //= "\t";
$method //= "sum";
$anno //= "#";
$mode //= "pipeline";
#$digi //=2;

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
    D:for my $line (@dd){
        next D unless length $line;
        next D if $line =~ /^$anno/;
        my @l = split/$sep/,$line;
        push @{$h{$l[$col1]}}, $l[$col2];
    }
    for my $k (sort {$a cmp $b} keys %h){
        my $stat_res = &Mstat(\@{$h{$k}}, $method);
        print "$k\t$stat_res\n";
    }
}

sub Mstat{
    my $ref = shift @_;
    my $met = shift @_;
    my @t = @{$ref};
    my $stat = Statistics::Descriptive::Full->new();
    $stat->add_data(@t);
    my @mets = split/,/,$met;
    my @p;
    for my $i (@mets){
        if($i eq "sum"){
            push @p, $stat->sum();
        }elsif($i eq "mean"){
            push @p, $stat->mean();
        }elsif($i eq "max"){
            push @p, $stat->max();
        }elsif($i eq "min"){
            push @p, $stat->min();
        }elsif($i eq "median"){
            push @p, $stat->median();
        }elsif($i eq "var"){
            push @p, $stat->variance();
        }elsif($i eq "sd"){
            push @p,$stat->standard_deviation();
        }elsif($i eq "count"){
	    push @p, $stat->count();
	}
    }
    for my $i (@p){
	#my $t = "%.".$digi."f";
	$i = sprintf("%.2f", $i);
	#my $t = "%.".$digi."f"; 
        #$i = sprintf($t, $i);
    }
    my $res = join",",@p;
    return $res
}

sub print_help{
    print STDERR "USAGE : perl $0 --mode [pipeline|file] --key_col [0] --value_col [1] --separation ['\\t'] --method [sum,mean,median,var,sd,max,min,count] --anno ['#'] --header\n";
}
