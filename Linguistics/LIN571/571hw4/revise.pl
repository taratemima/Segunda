#!/usr/bin/perl

#Because I am too lazy to do my fcfg myself, I am processing sentences and saving them in a separate file. That way, I have a list of #terminals without doing too much work. I hope.

sub FirstShot{

$/ = "";
open(WORDS, "feature_sentences.txt") || die "Cannot find the feature sentences file. \n";

my @words;
while(<WORDS>){
	chomp;
	@words = split;
	}

return @words;
}

sub Unique{
my @words = &FirstShot;
my %organized;

for(@words){
	$organized{$_}++;
	}

return my @all = keys %organized;
}

sub SaveToFile{
open(FCFG, ">fcfg.txt");
my @list = &Unique;

foreach my $v (@list){
	print(FCFG "$v \n");
	}

}

&SaveToFile;