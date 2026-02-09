#! perl

use warnings;
use strict;
#use MCE::Loop;

if(@ARGV < 2){
    print STDERR "USAGE: perl $0 \$ref \$gff1 \$gff2 ...\n";
    print STDERR "       support result from repeatmasker, repeatproteinmask and repeatmodeler, not support TRF\n";
    print STDERR "       the out file of this thress softwares can be converted to gff using command:\n";
    print STDERR "       `perl ConvertFormat_Repeat2gff.pl  \$inputfile \$outputgff TE|TP|Denovo [split_fa_len]`\n\n";
    print STDERR "       ambiguous region [region contains more than one repetitive annotation] were classed as the type which has the highest SW score\n";
    print STDERR "       i am not sure if it is suitalbe for classing ambiguous region, SW score can be comparable between difference repetitive sequence and softwares\n";
    print STDERR "       SW score threshold [225] applied for results, if you not want to filter, please modify script\n";
    print STDERR "       please consider carefully with result\n";
    exit;
}
#srand(time(NULL));
#my $random_n = int(rand() * 10000000);
#my $thread_mce = 10;
    
my $f_ref = shift;

my %ref = &load_ref($f_ref);
my %repeat;

for my $f (@ARGV){
    open IN,'<',$f or die "$!";
    while(<IN>){
	chomp;
	next unless length;
	my $type1 = "NA";
	my $type2 = "NA";
	my @l = split/\t/;
	next if $l[5] < 225;
	(my $tmp = $l[8]) =~ s/.*Class=//;
	$tmp =~ s/;.*//;
	my @type;
	if(exists $ref{$tmp}){
	    @type = @{$ref{$tmp}};	    
	}else{
	    print STDERR "can not regonize repetitive sequence type : [$tmp] in [$f]\n";
	    exit;
	}
	@{$repeat{$l[0]}{$l[3]}} = ($l[3],$l[4],$l[5],@type);
    }
    close IN;
}

&run(\%repeat);

sub run{
    my $rr = shift @_;
    my %h = %{$rr};
    my %m;
    my %t;
    my %c;
    for my $chr (sort {$a cmp $b} keys %h){
	my $block_l = 0;
	my @pos = sort {$a <=> $b} keys %{$h{$chr}};
	my @info = @{$h{$chr}{$pos[0]}};
	#print join"\t",@info;exit;
	my $block_s = $info[0];
	my $block_e = $info[1];
	my @types = @info[3..$#info];
	my $type = join"\t",@types;
	my $type_l = $info[1]- $info[0] + 1;
	my $type_s = $info[2];
	$t{$type_s} = [$type,$type_l];
	$c{$info[0]}{$info[1]} = $type_s;
	my $type_c;
	D:for (my $i = 1;$i < @pos;$i ++){
	    @info = @{$h{$chr}{$pos[$i]}};
	    if($block_s <= $info[1] && $info[0] <= $block_e){
		my @types = @info[3..$#info];
		my $type = join"\t",@types;
		my $type_l = $info[1] - $info[0] + 1;
		my $type_s = $info[2];
		if(exists $c{$info[0]}{$info[1]}){
		    if($c{$info[0]}{$info[1]} eq $type_s){
			next;
		    }
		}
		$block_s = $block_s < $info[0]?$block_s:$info[0];
		$block_e = $block_e > $info[1]?$block_e:$info[1];
		$t{$type_s} = [$type,$type_l];
	    }else{
		$block_l = $block_e - $block_s + 1;
		if(scalar keys %t > 1){
		    $type_c = "Ambiguous";
		}else{
		    $type_c = "Sole";
		}   
		my $high_s = (sort {$b <=> $a} keys %t)[0];
		my $type_lt = ${$t{$high_s}}[0];
		my $type_ll = ${$t{$high_s}}[1];
		my $type_lr = sprintf("%.3f",($type_ll/$block_l));
		$type_lr = $type_lr > 1 ? 1 : $type_lr;
		print join"\t",($chr,$block_s,$block_e,$type_lt,$type_ll,$type_lr,$type_c);
		print "\n";
		%t = ();
		%c = ();
		$type_c = "Sole";
		$block_e = $info[1];
		$block_s = $info[0];
		my @types = @info[3..$#info];
		my $type = join"\t",@types;
		$type_s = $info[2];
		$type_l = $info[1]- $info[0] + 1;
		$t{$type_s} = [$type,$type_l];
		
	    }
	}
	$block_l = $block_e - $block_s + 1;
	if(scalar keys %t > 1){
	    $type_c = "Ambiguous";
	}else{
	    $type_c = "Sole";
	}
	my $high_s = (sort {$b <=> $a} keys %t)[0];
	my $type_lt = ${$t{$high_s}}[0];
	my $type_ll = ${$t{$high_s}}[1];
	my $type_lr = sprintf("%.3f",($type_ll/$block_l));
	$type_lr = $type_lr > 1 ? 1 : $type_lr;
	print join"\t",($chr,$block_s,$block_e,$type_lt,$type_ll,$type_lr,$type_c);
	print "\n";
    }
    return 1;
}


sub load_ref{
    my $f = shift @_;
    my %h;
    open IN,'<',$f;
    while(<IN>){
	chomp;
	next unless length;
	my @l = split/\t/;
	$h{$l[0]} = [$l[1],$l[2]];
    }
    close IN;
    return %h;
}
