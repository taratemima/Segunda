#!/usr/bin/perl

#Code to get top five word frequencies and the documents that have it. 

use warnings;
use strict;
use diagnostics;

sub Counter{

my $document = $_[0];

#Make a word frequency count
my %seen;

while ($document = <>) {
	chomp;
	my @list = split;
    	#while ( /(\w['\w-]*)/gm ) {
	for (@list){
        		#$seen{lc $1}++;
		$seen{$_}++;
    			}
		}
return %seen;
}

sub OpenDoc{
$/ = "";

open(DOC, $_[0]) || die "Document not found";

my $text;
my %dictionary;

while(<DOC>){
	$text = $_;
	%dictionary = &Counter($text);
}

close DOC;

return %dictionary;
}


#sub RemoveStopwords{
#my @stopWords;
#open(STOP, "stop_words.txt") || die "Cannot find stopword list \n";

#while(<STOP>){
#	@stopWords = split;	
#	}
#close STOP;
#
#my %dictionary = &OpenDoc($_[0]);
#
#foreach my $s (@stopWords){
#	delete $dictionary{$s};
#	}

#return %dictionary;

#}


sub PrintResults{

#my %dictionary = &RemoveStopwords($_[0]);
my %dictionary = &OpenDoc($_[0]);
my $fileName = $_[1];


# output hash in a descending numeric sort of its values

print "$fileName Frequencies \n";

foreach my $word ( sort { $dictionary{$b} <=> $dictionary{$a} } keys %dictionary) {
	printf "%5d %s\n", $dictionary{$word}, $word;
	}

}

#sub SortingDirectory{
#opendir(SURVEY, $_[0]) || die "Cannot find directory \n";

#my @available = grep(-T, readdir(SURVEY));


#foreach my $a (@available){
#	&PrintResults($a, "$a");
#	}

#closedir SURVEY;
#}

#&SortingDirectory("./First");

