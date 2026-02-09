#! perl

use warnings;
use strict;

my $dir = shift;
$dir //= "./";

my @file = sort{$a cmp $b} grep{/coverage.report/} `find $dir`;
#map {print $_} @file;exit;
print "Sample\tData\tMapRate\tProperlyMapRate\tAverageDepth\tCoverage\n";
my %h;
foreach my $file (@file){
    #print $file;exit;
    chomp $file;
    (open IN,"< $file") or die "$!";
    my $name = "a";
    my $reads = "a";
    my $dp;
    my $coverage;
    my $map_rate;
    my $proper_map_rate;
    while(<IN>){
        chomp;
        if(/^## Files/){
            $_ =~ /\/(.*?)\..*/;
            $name = $1;
            print $name;
        }
        if(/\[Total\] Raw Data\(Mb\)\s+/){
            s/.*\t//;
            print "\t".$_;
            $h{$name} = $_;
        }
        if(/\[Total\] Fraction of Mapped Reads\s+/){
            s/.*\t//;
            $map_rate = $_;
            print "\t".$_;
            $h{$name} = "\t$map_rate";
        }
        if(/\[Total\] Fraction of Properly paired\s+/){
            s/.*\t//;
            print "\t".$_;
            $proper_map_rate = $_;
            $h{$name} .= "\t$proper_map_rate";
        }
        if(/\[Target\] Average depth\s+/){
            s/.*\t//;
            $dp = $_;
            print "\t".$_;
            $h{$name} .= "\t$dp";
        }
        if(/\[Target\] Coverage \(>0x\)\s+/){
            s/.*\t//;
            print "\t".$_;
            $coverage = $_;
            $h{$name} .= "\t$coverage";
        }
    }
    close IN;
    print "\n";
}
#print "Sample\tData\tMapRate\tProperlyMapRate\tAverageDepth\tCoverage\n";
#map{print "$_\t$h{$_}\n"} sort{$a cmp $b} keys %h;
