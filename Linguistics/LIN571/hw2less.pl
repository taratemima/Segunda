#!/usr/bin/perl

use warnings;
use diagnostics;
use strict;


sub BuildRules{
my @rules;


open(RULES, 'grammar-sample.txt') || die "could not find the grammar \n";
while(<RULES>){
	@rules = split(/\n/, $_);
	}

close RULES;
return @rules;
}


sub BuildSentences{
my @sentences;

open(SENT, 'sentences.txt') || die "could not find the text \n";

while(<SENT>){
	@sentences = split(/\n, $_);
	}

close SENT;
return @sentences;
}


sub BuildTable{
my @table;
my $sentence = $_[0];

my $i;
my $full = length($sentence);
my @round = split(/\s+/, $sentence);
for $i (0 .. $full){
	$table[$i] = [ @round ];
		}
return @table;
}

sub UpdateGrammarHash{
	my %array = $_[0];
	my $A = $_[1];
	my $B = $_[2];

	if(defined($array{$A})){
	$oldValue = $array{$A};
	$newValue = "$oldValue|$B";
	$array{$A} = $newValue;
		}
		elsif(!(defined($array{$A}))){
			$array{$A} = $B;
	}

return %array;
}




sub SeparateSentences{
my @sent = &BuildSentences;
my $sentence = pop(@sent);
return $sentence;
}
	

sub FillTerminalFromSentence{
my @rules = &BuildRules;
my $sentence = $_[0];

my @a_values;
my @b_values;
my %terminals;

my @elements = @rules;

#Will need rules to check if all is done correctly

while(@elements){
	
	my $first_rule = pop(@elements);

	(my $A, my $B) = split(/->/, $first_rule);
	push(@a_values, $A);

	if($B ~= m/^'(\w+)'$/){
		$B ~= s/'$1'/$1/;
		
	my @wordsInSentence = split(/\s+/, $sentence);
	foreach my $s (@wordsInSentece){
		if($s eq $B){
			my $related_A = pop(@a_values);
			#Here would be where I invoke a function to put the a value in the tables
			%terminals = &UpdateGrammarHash(%terminals, $related_A, $B);
						}
		elsif($s ne $B){
			$related_A = pop(@a_values);
			%terminals = &UpdateGrammarHash(%terminals, $related_A, $B);
					}
				}		
			}
	elsif($B ~! m/^'(\w+)'$/){
		push(@b_values, $B);
		}

	}

return @a_values;
return @b_values;
return %terminals;

}

sub MakingNewRules{
(my @a_values, my @b_values, my %terminals) = &FillTerminalFromSentence($_[0]);
my @newA = [qw(D,E,F,G,H,I,J,K,L,M,O,R,T,U,V,W,X,Y,Z)]

my @formed_a;
my @formed_b;

while((@a_values)&&(@b_values)){
	my $aTest = pop(@a_values);
	my $bTest = pop(@b_values);
	my @b_parts = split(/\s+/, $bTest);
	my $length = scalar(@b_parts);
	
	if($length < 2){
		my $b_split = pop(@b_parts);
		my $X = pop(@newA);
		my $C = join(/ /, @b_parts);
		my $new_b = join(/ /, $b_split, $X);
		push(@a_values, [$aTest, $X];
		push(@b_values, [$new_b, $C]; 
		}
	else{
		my $b_again = join(/ /, @b_parts);
		push(@formed_a, $aTest);
		push(@formed_b, $b_again);
		}
	}

return @formed_a;
return @formed_b;
return %terminal;
}


sub TotalHashFromTerminal{
(my @formed_a, my @formed_b, my %terminal) = &MakingNewRules($_[0]);

my %total = %terminal;

foreach my $A (@formed_a){
	foreach my $B(@formed_b){
		&UpdateGrammarHash(%total, $A, $B);
	}

return %total;
}

sub Connecting{
my $choice = &SeparateSentences;
my %totals = &TotalHashFromTerminal($choice);
my @table = &BuildTable($choice);

#put in something to decide from terminal to its a, then from the former a to its a
#Then for b and c statements, forward

}

#Put in something to count the created table

#sub PlaceInTables{
#my $startOrA = $_[0];
#my @table = $_[1];
#my $productionOrB = $_[2];
#my %terminals = $_[3];

#for(my $j = 1; $j < $#table; $j++){
#	for(my $i = ($j - 2); $i > 0; $i--){
#		for(my $k = ($i + 1); $k > ($j - 1); $k++){
#			$table[$i][$j] = $start;
#			(my $b, my $c) = split(/\s+/, $productionOrB);
#			$table[$i][$k] eq $b;
#			$table[$k][$j] eq $c;
#			}	
#		}
#	}
#}