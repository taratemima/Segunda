#!/usr/bin/perl

use warnings;
use diagnostics;
use strict;

sub Parameters{

my $target_string = $_[0];
my $source_string = $_[1];
my $target_length = length($target_string);
my $source_length = length($source_string);

#I'll need to put something in to make sure that everything is all lined up. 

my @matrix;
#my @target = (split(/\s/, $source_string));
#my @source = split(/\s/, $target_string);
my @target = split(//, $source_string);
my @source = split(//, $target_string);

for my $i (1..($source_length + 1)){
	$matrix[$i] = [$target[$i]];
	}

for my $j (1..($target_length + 1)){
	$matrix[0][$j] = $target[$j - 1];
	}

for my $k (1..($source_length + 1)){
	$matrix[$k][0] = $source[$k - 1];
	}

#$matrix[0][0] = 0;

for my $c (1..($target_length + 1)){
	for my $d (1..($source_length + 1)){
		if($matrix[0][$c] eq $matrix[$d][0]){
			$matrix[$d][$c] = 0;
			}
		elsif($matrix[0][$c] ne $matrix[$d][0]){
			$matrix[$d][$c] = 1;
			}
		}
	}

for my $aref (@matrix){
	print "\t [@$aref], \n";
	}

}

&Parameters("intention", "execution");