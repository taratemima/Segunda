#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;

my @nyt = </corpora/LDC/LDC02T31/nyt/2000/2000*_NYT>;

#my %nytD = {};
#my @words = [];
#my @tallies = [];

foreach my $c (@nyt){
open(TEXT, "$c") || die "Cannot open newsfile"; 
while (<TEXT>){

my $nytstring = $_;

#$nytstring = s/[\W]//g;
#$nytstring = s/<(?:[^>'"]*|(['"]).*?\1)*>//gs;

#when I do that, it changes the text into numbers . . . huh
#While there are modules to remove HTML, I decided to go for the one 
#liner to account for html continuing over lines

#$nytstring = s/(<.>)/""/g;
#$nytstring = s/[A-Z]/[a-z]/;
#$nytstring = s/(.'.)/../g;

my @wordsToEnter = split(/\s+/, $nytstring);
for (my $w = 0; $w < 5; $w++){
print wordsToEnter[$w];
		}
	}
close(TEXT);
}

#Replace apostrophe with letters before and after it





#foreach my $w (@nyt){
#print $w;
#	if ($nytD{$w} == ""){
#                  $nytD{$w} = 1;
#               }else{
#                       $nytD{$w} += 1;
#                       }



	

#@sortedvalues = sort by_values keys(%nytD);

#sub by_values{
#       ($nytD{$a} cmp $nytD{$b}) || ($a cmp $b);
 

#foreach (@sortedvalues){
#     print "$_ : \t $nytD{$_}\n";
#
