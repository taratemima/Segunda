#!/user/bin/perl
use warnings;
use strict;
use diagnostics;
#use Math::Trig ':pi';

$/ = "";
sub Create2gramHMM{
#(my $twoGramFile, my $outputFile) = @ARGV;


my @probability_storage = (
{
	Word => "Tara",
	POS => "NNP",
	Number => 1,
		},
	);

open (POS, 'wsj_sec0.txt');

while(<POS>){
my %pairs;
my $figure = "/";
chomp;
	my @lines = split(/\s+/, $_);
	foreach my $line (@lines){
		while ( $line =~ m/(\b[^\W_\d][\w'\/-]+\b)/gm ) {
		$pairs{$1}++;
			}
		}

	my @words = (keys %pairs);
	for (my $w = 0; $w < $#words; $w++){
		$probability_storage[$w]{Number} = $pairs{$words[$w]};
		(my $word, my $partOfSpeech) = split(/\//m, $words[$w], 2);
		$probability_storage[$w]{Word} =$word;
		$probability_storage[$w]{POS} = $partOfSpeech; 
				}
		
		}		
	return @probability_storage;

	


}

#I replaced \/ with | or &. I did not like that idea, but the regex given in GoPost either did not work or I applied it all wrong
#It cannot seem to substitute \/ without affecting /

sub PrintArrayofHash{

my @prob = &Create2gramHMM;
# print the whole thing with indices
	for (my $i = 0; $i < $#prob; $i++ ) {
		print "$i is { ";
			for my $word ( keys %{ $prob[$i] } ) {
			print "$word=$prob[$i]{$word} ";
				}
				print "}\n";
	 }


}

&PrintArrayofHash;