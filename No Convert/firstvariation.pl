#!/usr/bin/perl

$line1 = "I confess I have not programmed in ten years.";
$line2 = "If I knew how to program, I would get a better job.";


$story = "${line1}" . " " ."${line2}";

print $story;

#I have made two string variables and joined them


#Confession:
#Make array for each of the sentences in the text file. Do not edit the original text file
#just yet.
#Have the array count be 0-24, and a warning if the text file is longer than that
#Print results

#sub start-story{
# $line1 = "I confess I have not programmed in ten years.";
#$line2 = "If I knew how to program, I would get a better job.";
#@story = ($line1, $line2);
#}
#sub init_words {
#open (CONFESS, "originaltext.txt");
#while ($line = <CONFESS>) {
#for (i = 0; i <=24; i++){
#push(@story, $line[i]);
#}
#}
#}
#close(CONFESS);
#}

#Clumsy code reuse from Learning Perl