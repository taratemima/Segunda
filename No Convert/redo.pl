#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;
use Switch;

open (EXAMPLE, "ex") || die "Example not found";

while (<EXAMPLE>){
	my $test = $_;
	chomp;
my @TheLetters = [];

sub Prepare{
my $input = $_[0];
return $input =~ s/"//;
}


sub Divide{
my $input = &Prepare($_[0]);
my @examples = split /\s+/, $input;
return @examples;
}

@TheLetters =  &Divide($test);


#FSAs are a boolean
#Results prints out the lines

#I am not sure if I want to have the input supplied by the user. The input is the same, but hard-coded.


sub FSAstart{
#my $state = $starts{state};
my $state = 1;
my @letters = @TheLetters;
switch ($state){
case 1{
	foreach my $w (@letters){
		if ($w eq "c"){
			$state = 9;
			}
				else{
					$state = 2;
				}	
		}
	}

case 2{
	foreach my $w (@letters){
	if ($w eq "a"){
			$state = 3;		
		}
	}
}
	
case 3{
	foreach my $w (@letters){
	if ($w eq "a"){
			$state = 4;
		}
			elsif ($w eq "b"){
				$state = 5;
				}
	}
}

case 4{
	foreach my $w (@letters){
	if ($w eq "a"){
	$state = 5;
			}
	elsif ($w eq "b"){
	$state = 5;
		}
	}
}

else {
	return $state;
		}
	}
}


sub FSA1{
my $state = &FSAstart;
my @letters = @TheLetters;

switch ($state){
case 5{

#"a" "a"
#"a" "b"
#"a"
#"b"
#"b" "b"
	
#Case 4 checks the first letter
#Case 5 checks the second letter

foreach my $w (@letters){
			if ($w eq ""){
				$state = 9;
			}
				elsif ($w eq ("a" || "b")){
					$state = 6;
			} 
		}
}

case 6{
foreach my $w (@letters){
	if ($w eq ""){
		$state = 8;
				}
		elsif ($w eq ("a" || "b")){
			$state = 7;
			}			
		}
	}

else {return $state;}
	}

}


sub FSA2{
my $state = &FSAstart;
my @letters = @TheLetters;

#a+b*

switch ($state){
case 5{

#"a" "a"
#"a" "b"
#"a"

#Case 5 checks the first letter
#Case 6 checks the second letter

foreach my $w (@letters){
	if ($w eq ""){
		$state = 9;
			}
		elsif ($w eq "a"){
			$state = 6;
			}
			elsif ($w eq "b"){
				$state = 9;
			}
		}
	}

case 6{
	foreach my $w (@letters){
		if ($w eq ("a"|| "b")){
			$state = 6;
			}
			elsif ($w eq ""){
				$state = 7;
			}
		}
	}

else {return $state;}
	}
}


sub FSA3{
my $state = &FSAstart;
my @letters = @TheLetters;

#a*b+

switch($state){
case 5{

#"a" "a"
#"a" "b"
#"a"
#"b"
#"b" "b"
#Case 4 checks the first letter
#Case 5 checks the second letter

	foreach my $w (@letters){
		if ($w eq ""){
		$state = 9;
					}
		elsif ($w eq "a"){
			$state = 6;
				}
			elsif ($w eq "b"){
				$state = 7;
			}
		}
	}

case 6{
	foreach my $w (@letters){
		if ($w eq "b"){
			$state = 7;
					}
			elsif ($w eq ""){
				$state = 8;
				}	
				elsif ($w eq "a"){
					$state = 5;
			}
		}
	}

else {return $state;}
	}
}


sub FSA4{
my $state = &FSAstart;
my @letters = @TheLetters;

switch($state){
case 5{

#"a" "a"
#"a" "b"
#"a"
#"b"
#"b" "b"
#Case 4 checks the first letter
#Case 5 checks the second letter

foreach my $w (@letters){
			if ($w eq ""){
				$state = 9;
			}	
				elsif ($w eq "b"){
					$state = 9;
			}
				elsif ($w eq "a"){
					$state = 6;
			}
		}
}
case 6{
#we are looking at 
#a, a
#a, b
	foreach my $w (@letters){
		if ($w eq ""){
			$state = 9;
				}
				elsif ($w eq "a"){
					$state = 5;
				}
					elsif ($w eq "b"){
						$state = 7;
			}

		}	
	}

else{return $state;}
	}
}

sub FSAFinish{
my @letters = @TheLetters;
my $state = $_[0];
switch ($state){
case 7{

foreach my $w (@letters){
	if ($w eq ""){
			$state = 8;
		}
			elsif ($w eq "a"){
				$state = 9;
		}
			elsif ($w eq "b"){
				$state = 7;
		}

	} 

}


case 8{
	return 1;
}

case 9{
	return 0;
			}

		}
	
	}


#accepts number, returns boolean


sub Results{
if ($_[0] == 1){
#that is, true
	print $_[1];
	print "\t =>";
	print "yes \n";
		}
		elsif ($_[0] == 0){
			print $_[1];
			print "\t =>";
			print "no \n";
	}

#prints from boolean
}

&Results((&FSAFinish(&FSA1)), $test);
&Results((&FSAFinish(&FSA2)), $test);
&Results((&FSAFinish(&FSA3)), $test);
&Results((&FSAFinish(&FSA4)), $test);

}
