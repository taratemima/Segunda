#!/usr/bin/perl

use warnings;
use strict;
use diagnostics;

sub Question1and3{
open (FILE, "ex1") || die "No such file \n";

while (<FILE>){
my $string = $_;
chomp;
my @wordKeys = [];

$string =~ tr/a-zA-Z'\(\)\-,.\?!;:/\n/cs;

#This is so empty spaces are not counted
#split /[\-\.,\(\)\s+'"]/, lc( $string );

if ($string =~ m/&/){
	$string =~ s/&/and/;
				}
elsif ($string =~ m/%/){
	$string =~ s/%/percent/;
			}
else{
	@wordKeys = split (/\s+, $string/);
	}	
#elsif ($string !~ m/[\(\-\.\),:;!]/){
#@wordKeys = split (/\s+/, $string);
#}
#elsif($string =~ m/[\(\-\.\),:;!]/){			
#@wordKeys = split (/[\(\-\.\),\$"';\s+]/, $string);
#}
#It will not take out the empty array elements, and it seems to miss words that are alike (air, for one). Why?
my %wordList;
foreach my $w (@wordKeys){
	next if $wordList{$w}++;

		#if ($w eq ""){
		#	splice (@wordKeys, 0, 1);
	#}
	print $w;
	print " \n";
		
}

#frequency of tokens in descending order
#Thank you Esad
#foreach my $key (keys %wordList) {
#print ("$wordList{$key}\t$key\n");
#}




#return %wordList;
#print keys %wordList;



	}			
close (FILE);

}


&Question1and3;

#s1lk-Eye