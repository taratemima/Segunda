#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;
use 5.010;
use Switch;

open (EXAMPLE, "ex") || die "Example not found";

while (<EXAMPLE>){
	my $test = $_;
	chomp;

&Results(&FSA1($test), $test);
&Results(&FSA2($test), $test);
&Results(&FSA3($test), $test);
&Results(&FSA4($test), $test);

#FSAs are a boolean
#Results prints out the lines


sub Results{
if ($_[0] == 1){
#that is, true
	print $_[1];
	print "\t =>";
	print "yes \n";
		}
		else{
			print $_[1];
			print "\t =>";
			print "no \n";
	}
}

sub Prepare{
my $input = $_[0];
return $input =~ s/"//;
}

sub OrderTest{
my $input  = &Prepare($_[0]);
if ($input =~ m/\ba+b{2,}\b/){
	return 1;
		}
	elsif (($input =~ m/a+b+a+/)||($input =~ m/\bb+a+/)){
	return 0;
	}
}


sub Divide{
if (&OrderTest == 1){
my @examples = split /\s+/, $input;
return @examples;
	}
}

#There seemed to be no 'if non-essential string is there, keep checking until you find an essential string or return false' provision #in Carmel or else I assumed we were not working with probabilistic acceptors
#So, I assume that the commands did not have to mirror Carmel exactly because until I understand how to mirror what I want in 
#Carmel, I rather not do that.

sub FSA1{
my @letters = &Divide($_[0]);
foreach my $w (@letters){
switch ($w){

case "a"{ 
	return 1;
	break;	
	}
case "b"{
	return 1;
	break;
	}
else{
	return 0;
	break;
			}
		}
	}
}


sub FSA2{
my @letters = &Divide($_[0]);

#a+b*
foreach my $w (@letters){
switch ($w){

case "a"{ 
	return 1;
	break;	
	}
case "b"{
	if ("a" ~~ @letters){ 
	return 1;
	break;
		}
	}	
else{
	return 0;
	break;
			}
		}
	}
}


sub FSA3{
my @letters = &Divide($_[0]);

#a*b+
foreach my $w (@letters){
switch ($w){

case "a"{ 
	if ("b" ~~ @letters){
		return 1;
		break;
	}
}
	
case "b"{
	return 1;
	break;
	}
		
else{
	return 0;
	break;
			}
		}
	}
}


sub FSA4{
my @letters = &Divide($_[0]);

#a+b+

foreach my $w (@letters){
switch ($w){

case "a"{
	if ("b" ~~ @letters){
		return 1;
		break;
	}
}
	
case "b"{
	if ("a" ~~ @letters){
		return 1;
		break;
			}
	}
else{
	return 0;
	break;
				}
			}
		}
	}
}

