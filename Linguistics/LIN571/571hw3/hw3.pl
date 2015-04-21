#!/usr/bin/perl

use warnings;
use diagnostics;
use strict;

#Tara Edwards

#I am pretty sure none of this works. I had coded it quickly after doing lots of pseudocode in my notebook. I had used the Probablistic CKY 
#algorithm, but tried to combine it with the Chart Parse algorithm. It seemed that going at both ends would make the process faster, and it #seemed a better way of doing than what I did in homework 2. I do not think it went well, but I gave it my best shot.
#Uncommented code is at least OK in syntax. That is no guarantee that it works. 

sub BuildRules{
my @rules;


open(RULES, 'parsetrain.txt') || die "could not find the grammar \n";
while(<RULES>){
	@rules = split(/\n/, $_);
	}

close RULES;
return @rules;
}


sub BuildSentences{
my @sentences;
open(SENT, 'sentstest.txt') || die "could not find the text \n";

while(<SENT>){
	@sentences = split(/\n/, $_);
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
	my $oldValue = $array{$A};
	my $newValue = "$oldValue|$B";
	$array{$A} = $newValue;
		}
		elsif(!(defined($array{$A}))){
			$array{$A} = $B;
	}

return %array;
}


sub CreateAgenda{
	(my $sentence, my %hash) = @_;
	my @availableA = (keys %hash);
	my @agenda = split(/\s+/, $sentence);
	foreach my $a (@availableA){
		unshift(@agenda, $a);
	}
	return @agenda;
}

#sub PlacePOSInTable{
#(my @table, my $sentence, my @created) = @_;
#(my %total, my %probableIndex) = &MakingProbableAndRuleHashes(@created);
#my @agendaT = &CreateAgenda($sentence, %total, %probableIndex);
#my @answers;
#my @calc = @table;

#for(my $j = 1; $j < $#table; $j++){
#	for(my $i = ($j - 2); $i > 0; $i--){
#		for(my $k = ($i + 1); $k > ($j - 1); $k++){
#			while(@agendaT){
#				my $current = pop(@agendaT);
#				(@answers, @agendaT, my $m, my $n) = &ProcessEdge($current, @agendaT, $j, $i, $k, @table);
#				foreach my $p (@answers){
#					@table = &UpdateTable($p, @table, $m, $n);
#					}
#				}
#			}	
#		}
#	}
#return @table;
#}

sub UpdateTable{
(my $entry, my @table, my $row, my $column) = @_;

if($table[$row][$column]){
	my $old = $table[$row][$column];
	$table[$row][$column] = (join(",", $old, $entry));
		}
	else{
	$table[$row][$column] = $entry;
	}

return @table;

}

#sub CreateCalcTable{
#(my @table, my %probableIndex) =@_;
#for(my $j = 1; $j < $#table; $j++){
#	for(my $i = ($j - 2); $i > 0; $i--){
#		for(my $k = ($i + 1); $k > ($j - 1); $k++){
#	@calc = &CalculateTables(@table, %probableIndex, $j, $i, $k);
#			}
#		}
#	}
#return @calc;
#}

sub CalculateTables{
my (@table, my %index, my $j, my $i, my $k) = @_;

my @a_val = split(/,/, ($table[$j -1][$j]));
my @b_val = split(/,/, ($table[$i][$k]));
my @c_val = split(/,/, ($table[$k][$j]));

while((@a_val)&&(@b_val)){
	my $starterA = pop(@a_val);
	my $starterB = pop(@b_val);
	my $starterC = pop(@c_val);
	my $state = "$starterA->$starterB $starterC";

	my $ruleValue = $index{$state};

	if($table[$i][$j] < ($ruleValue * $starterB * $starterC)){
		$table[$i][$j] =($ruleValue * $starterB * $starterC);
			}
	elsif($table[$i][$j] =~ m/\D/){
		$table[$i][$j] = 1;
		}
	}
return @table;
}

#GetFinalAnswer{Get a calc table, go to [0][1], and get the answer}

sub PrintRules{
(my %total, my  %probableIndex) = @_;
open (RULES, ">>rules.txt");

foreach my $r (keys %total){
	my $completedRule = join("->", $r, $total{$r});
	print(RULES "$completedRule [ $probableIndex{$completedRule} ] \n");
	}

}

sub PrintTestParse{
	(my @parsedSentences, my $final_answer) = @_;
	open (FINAL, ">>parsedsents.txt");

	foreach my $s (@parsedSentences){
		print(FINAL "$s \n");
	}
}

#sub MakingProbableAndRuleHashes{
#	(my @rulesList, my %ruleIndex) = &TransformTraining;
#	my %probabilityIndex;
#	my %count;
#	my $total = scalar(@rulesList);
#
#	for(@rulesList){
#		$count{$_}++;
#		}
#
#	while(($rule, $count) = each %count){
#		$probabilityIndex{$rule} = ($count/$total);
#	}
#	my @newList = (keys $probabilityIndex);
#
#	foreach my $f (@newList){
#		(my $a, my $rest) = split(/->/, $f, 2);
#		&UpdateGrammarHash(%ruleIndex, $a, $rest);
#	}

#	return %ruleIndex;
#	return %probabilityCount;
#}

sub ProcessEdge{
	(my $edge, my @agenda, my $j, my $i, my $k, my @table) = @_;

	my @chart;
	my $row;
	my $column;
	
	if($edge =~ /$table[$i][$j]/m){
		@chart = split(/,/, ($table[$j][$k]));
		push(@chart, $edge);
		$row = $j;
		$column = $k;
		push(@agenda, (split(/,/, ($table[$i][$k])))); 
		}
	elsif($edge =~ /$table[$j][$k]/m){
		@chart = split(/,/, ($table[$i][$j]));
		push(@chart, $edge);
		$row = $i;
		$column = $j;
		push(@agenda, (split(/,/, ($table[$i][$k])))); 

	}

return (@chart, @agenda, $row, $column);

}

#sub TransformTraining{
#	my @training = &BuildRules;
#	my %totals;

#	foreach my $t (@training){
#		%totals = &FindTerminals($t);
#		@rules = &CNFConvert($t, @rules);
#	}


#	return @rules, %totals;

#}

sub FindTerminals{
	my $sentence = $_[0];
	my %index;
	my $tag;
	my $word;

	if($sentence =~ m/\((\w+ \w+)\)/m){
		$tag = $1;
		$word = $2;
		&UpdateGrammarHash(%index, $tag, $word);
	}

return %index;

}

#sub CNFConvert{

#	(my $sentence, my @collection) = @_;

#	my @a_values;
#	my @b_values;
#	my @c_values;

#	my $start = "TOP";

#I went through the process of reducing a Treebank sentence into CNF form, but I want to balance recrusion with accounting for 
#unusual sentences

#(TOP (S (NP_PRP I) (VP (VBP need) (NP (NP' (NP' (NP (DT a) (NN flight)) (PP (TO to) (NP_NNP Seattle))) (VP (VBG leaving) (PP (IN from) #(NP_NNP Baltimore)))) (VP (VBG making) (NP (NP (DT a) (NN stop)) (PP (IN in) (NP_NNP Minneapolis))))))) (PUNC .))

#$sentence =~ s/\(\w+ \w+\)/\(\w+\)/;
#	while($sentence){
		
#		if($sentence ~= m/^\($start/){
#			push (@a_values, $start);
#			$sentence ~= s/^\($start /^ /;
#			
#				if($sentence ~= m/^\((\w+) \)/)
#					$start = $1;
#					push(@b_values, $start);
#						}
#					elsif($sentence ~= m/^\((\w+\) /){
#						push(@b_values, $1);
#						$sentence ~= s/^\($1\)/^ /;
#					}
#				if($sentence ~= m/\((\w+)\)$/){
#					push(@c_values, $1);
#					$sentence ~= s/\($1\)$/ $/;
#				}
#					elsif($sentence ~= m/\){2,}$/){
#						$sentence ~= s/\)$/ $/;
#
#			}
#
#		}
#	}

#Here would be the loop to take the a, b, c values by the same index number and join them, first the b and c values by white space, if #(defined($c_values[$index]), then with the a value with "->". Put the string into @collection. Return @collection.
#}

#To create @parsedSentences, use %rulesIndex and %probableIndex;
#Build a CKY table for each test sentence
#If there is one choice for the terminals, substitute word with (tag word)
#If there is more than one, make strings with format A->B C
#Compare values of the strings in %probableIndex, and use the rule with the highest probability