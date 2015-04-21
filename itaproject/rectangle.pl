#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

sub CreateWordList{
	$/ = "";
        open(STOP, "wordList.txt") || die "Word list file not in folder \n";
        my @words;

        while(<STOP>){
                chomp;
                @words = split;
        }

return @words;
}

#I saved word.lst as text because I was worried that my code would not recognize it as text otherwise
#OK, without paragraph mark, split gets only the last word. With paragraph mark, it gets more words--out of order, but that was my fault.

sub WordLengthHash{
my %length;

my @words=&CreateWordList;

foreach my $w (@words){
	$length{$w} = length($w);
	}

return %length;
}
#Have word length as value 

sub GettingLongestLength{
	my %length = &WordLengthHash;
	my @picks = reverse(sort ({$a <=> $b;} values %length));
	return my $top = pop(@picks);

#I'll bet there is something wrong with the sort function, like I ought to add things
#If that is so, why aren't there any words in the down array?
}

sub AcrossAndDownWords{
	my %length = &WordLengthHash;
	my $top = &GettingLongestLength;

	my @acrossWords;
	my @downWords = keys %length;

	while($top > 2){
	my @choices;
	
	for(my $i = 0; $i < $#downWords; $i++){
		my $test = $downWords[$i];
		if(($length($test) == $top){
			push(@choices, $test);
					}
		if((scalar(@choices)) >= 2){
			@acrossWords = @choices;
				}
		elsif((scalar(@choices)) <= 1){
			pop(@choices);
			$top--;
			}
		}
	}



return @acrossWords;
return @downWords;
}

#Get an array of words with the longest length, then get words that are shorter than that. 

#Put in subroutine that finds difference between across words and down words

#sub UpdateHash{
#	my %list = $_[0];
#	my $key = $_[1];
#	my $value = $_[2];

#	if(defined($list{$key})){
#		my $old = $list{$key};
#		my $new = join(';', $old, $value);
#		$list{$key} = $new;
#	}
#	elsif(!(defined($list{$key}))){
#		$list{$key} = $value;
#	}

#return %list;
#}

#To store substring matches for each word



sub FindPositions{
	(my @across, my @down) = &AcrossAndDownWords;
	my $limit = &GettingLongestLength;
	my %scores;
	my $downLength = scalar(@across);

	foreach my $target (@across){
		if((length($target)) == $limit){
			$scores{$target} = "across";
		}
	}
	
	foreach my $choice (@down){
		if((length($choice)) <= $downLength){
			$scores{$choice} = "down";
		}
	}

#	foreach my $target (@across){
#		for (my $x = 0; $x < (length($target)); $x++){
#			foreach my $choice (@down){
#				for (my $y = $downLength; $y > 0; $y--){
#					if((substr($choice, $y, 1)) eq (substr($target, $x, 1))){
#						&UpdateHash(%scores, $target, $x);
#						&UpdateHash(%scores, $choice, $y);
#					}
#				} 
#			}
#		}
#	}

return %scores;
}

#OK, when I ran the script, I got nothing in the output. So, I guess there is something wrong with the search logic

#sub BuildSquare{
#	my $seed = $_[0];
#	my $squareLength = &GettingLongestLength;
#	my @square;
#	my @seed = split(//,$seed);

#	for my $i (1..($squareLength + 1)){
#		$square[$i] = [$seed[$i -1]];
#		$square[0][$i] = $seed[$i -1];
#	}

#return @square;


#}

sub PrintAnswers{
	open(OUT, '>newoutcomes3.txt');
	my %scores = &FindPositions;
	
	while ((my $word, my $places) = each %scores){
	print (OUT "$word : $places \n");
	}

}

#Do I drop a letter at a time, do substring searches, or find unique intersecting letters?
#Do I make English-allowed combos and build with that?

&PrintAnswers;

#Get the words that match the first letter of every word in across words
#If a first letter does not match anything, delete that word
#Look in the same list for words that match the second letter of every word in across words
#Continue until all the letters in the remaining words are accounted for.
#If there are no choices left, decrement the across length and start everything from AcrossAndDownWords onward

#Count the number of across words left
#Pop anything from down words that is longer than the number of across words
#Make sure a word matches all the n letters before taking it out, breaking it up, and putting it in the square
#Make sure that the across of the 2d square matches the across words
#Make sure that the down of the 2d square matches the across words, and makes a word 

#Most people say that the solution is 7x7, or 8x8 if you are patient
#I intrepreted the problem as longest horizontal (across) words
#I wonder if the first two letter idea I had would work better than what I am doing

#Another thing to account for: After nearly every snippet of code I wrote in the interview, someone asked me: "what's the pathological #case for this? What kind of input would cause this to take forever?" It's an interesting question, and clearly something they're quite #concerned with (you can't just not respond to a web request for flights if the user happens to enter tricky data). If you're going to #interview, it'd be a good idea to get in the habit of asking yourself this question about your code.