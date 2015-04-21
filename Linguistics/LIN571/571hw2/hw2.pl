#!/usr/bin/perl

use warnings;
use diagnostics;
use strict;

#Tara Edwards

sub BuildRules{
$/= "";
my @rules;


open(RULES, 'grammar.txt') || die "could not find the grammar \n";
while(<RULES>){
	@rules = split(/\n/, $_);
	}

close RULES;
return @rules;
}


sub BuildSentences{
$/= "";
my @sentences;
open(SENT, 'sentences.txt') || die "could not find the text \n";

while(<SENT>){
	@sentences = split(/\s+/, $_);
	}

close SENT;
return @sentences;
}




#Maybe I should process the whole sentences document all at once rather than try to do line-by-line

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
	my $oldValue = $array{$A};
	my $newValue = "$oldValue|$B";
	$array{$A} = $newValue;
		}
		elsif(!(defined($array{$A}))){
			$array{$A} = $B;
	}

return %array;
}

sub FillTerminalFromSentence{
my @rules = &BuildRules;
my $sentence = $_[0];

my @a_values;
my @b_values;
my %terminals;

my @elements = @rules;

#Will need rules to check if all is done correctly

foreach my $r (@elements){
	(my $A, my $B) = split(/->/, $r, 2);
	my $related_A;
	push(@a_values, $A);

	if($B =~ m/^(\w+)$/i){
		$B =~ s/'$1'/ $1 /;
	my @wordsInSentence = split(/\s+/, $sentence);
	foreach my $s (@wordsInSentence){
		if($B =~ /$s/){
			$related_A = pop(@a_values);
			%terminals = &UpdateGrammarHash(%terminals, $related_A, $B);
						}
		elsif($B !~ /$s/){
			$related_A = pop(@a_values);
			%terminals = &UpdateGrammarHash(%terminals, $related_A, $B);
					}
				}		
			}
	elsif($B !~ m/^('\w')$/i){
		push(@b_values, $B);
		}
	}

return @a_values;
return @b_values;
return %terminals;

}

#I think the problem is the regular expressions may be not allowing data to get saved. 

sub MakingNewRules{
(my @a_values, my @b_values, my %terminals) = &FillTerminalFromSentence($_[0]);
my @newA = (qw(D E F G H I J K L M O R T U V W X Y Z));

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
		my $C = join(" ", @b_parts);
		my $new_b = join(" ", $b_split, $X);
		push(@a_values, [$aTest, $X]);
		push(@b_values, [$new_b, $C]); 
		}
	else{
		my $b_again = join(" ", @b_parts);
		push(@formed_a, $aTest);
		push(@formed_b, $b_again);
		}
	}

return @formed_a;
return @formed_b;
return %terminals;
}


sub TotalHashFromTerminal{
(my @formed_a, my @formed_b, my %terminal) = &MakingNewRules($_[0]);

my %total = %terminal;

foreach my $A (@formed_a){
	foreach my $B(@formed_b){
		&UpdateGrammarHash(%total, $A, $B);
		}
	}
return %total;
}

sub Connecting{
my @sent = &BuildSentences;

foreach my $choice (@sent){
	if($choice){
	my %totals = &TotalHashFromTerminal($choice);
	&FillTerminalFromSentence($choice);
	my @table = &BuildTable($choice);

	my %constituents;
	my @choice_sentence;
	my @possible_a;
	my @mostly_b;

	(%constituents, @choice_sentence, @possible_a, @mostly_b) = &Breaking(%totals, $choice);
	&PlaceInTables(@table, %totals, @choice_sentence, %constituents, @possible_a, @mostly_b);
		}
	}
}

sub Breaking{
(my %totals, my $sentence) = @_;
my @keys = (sort(keys %totals));
my @sentence_bits = split(/\s+/, $sentence);

my %breakups;

grep($breakups{$_}, (sort(split(/\|/, (values %totals)))));

my @pures = grep(!$breakups{$_}, @keys);

return (%breakups, @sentence_bits, @keys, @pures);

#This develops hash of the values of the original, breaks the sentence into an array, an array of keys for the new hash, and an array
#of keys from the original not found in the new hash.

}

sub UpdateTable{
(my @table, my $parse, my $row, my $column) = @_;
for my $i (0 .. 20){
	$table[$i] = [  ];
		}

if($table[$row][$column]){
	my $old = $table[$row][$column];
	my $new = join(",", $old, $parse);
	$table[$row][$column] = $new;
	}
elsif(!(defined($table[$row][$column]))){
	$table[$row][$column] = $parse;
	}

return @table;
}

sub BottomUp{
(my $j, my $i, my $k, my %constituents, my @sentence, my @con_keys, my @possible_b, my @table, my %totals) = @_;
	foreach my $m (keys %totals){
		if($sentence[$j - 1] =~ m/$totals{$k}/m){
			@table = &UpdateTable(@table, $m, ($j - 1), $j);
			}
		foreach my $n (@con_keys){
			if($totals{$k} =~ m/$n/m){
				@table = &UpdateTable(@table, $m, $i, $j); 
				@table = &UpdateTable(@table, $n, $k, $j);
			}
		}
		foreach my $p (@possible_b){
			if($totals{$k} =~ m/$p/m){
				(my $b, my $c) = split(/\s+/, $p);
				@table = &UpdateTable(@table, $m, $i, $j); 
				@table = &UpdateTable(@table, $b, $i, $k); 				
				@table = &UpdateTable(@table, $c, $k, $j);
			}
		}
	}
return @table;
}

sub TopDown{
(my @table, my %totals, my $j, my $i) = @_;
my $start_symbol = "TOP";

if(($table[$j - 1][$j]) !~ m/$start_symbol/){
	my @possibles = split(/,/, ($table[($j - 1)][$j]));
	$start_symbol = pop(@possibles);
		}
else{
	my $row = $j - 1;
	print "$start_symbol is at row $row and column $j \n";
	}

}

sub PlaceInTables{
(my @table, my %total, my @sentence, my %constituents, my @con_keys, my @poss_b) = @_;

for(my $j = 1; $j < $#table; $j++){
	for(my $i = ($j - 2); $i > 0; $i--){
		for(my $k = ($i + 1); $k > ($j - 1); $k++){
			@table = &BottomUp($j, $i, $k, %constituents, @sentence, @con_keys, @poss_b, @table, %total);
			&TopDown(@table, %total, $j, $i); 
			}	
		}
	}
}

&Connecting;

