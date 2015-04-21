#!/usr/bin/perl

use warnings;
use diagnostics;
use strict;

sub GrabText{
        $="";
        open(TEXT, $_[0]) || die "Cannot find file \n";
        my $string;

        while(<TEXT>){
                chomp;
                $string = $_;
        }

return string;

}

sub Tokenize{
        my @tokens;
        my $FileString = &GrabText($_[0]);
        $FileString =~ s/[\.:;\(\)]/ /gm;
        $FileString =~ tr/[A-Z]/[a-z]/gm;
        @tokens = split(/\s+/, $FileString);

        return @tokens;

}

sub GettingTheTextFiles{
        opendir(CONVERSE, $_[0]) || die "Could not find folder \n";
        my @textFiles = grep(-T, readdir(CONVERSE));
        return @textFiles;

}

sub CollectingResults{
        my @textFiles = &GettingTheTextFiles([$_0]);
        my @results = &Tokenize($textFiles[0]);

        for (my $i = 1; $i < $#textFiles; $i++){
                my @fileResults = &Tokenize($textFiles[$i]);
                foreach my $r (@fileResults){
                        push(@results, $r);
                }
        }

return @textFiles;
return @results;
}

sub MakeStopwords{
        open(STOP, "stop_words.txt") || die "Stop words file not in folder \n";
        my @stopwords;

        while(<STOP>){
                chomp;
                @stopwords = split;
        }

return @stopwords;
}

sub ClearOutStopwords{
        my @results = $_[0];
        my @stop = &MakeStopwords;
        my %clear;

        grep($clear{$_}++, @stop);
        my @clearResults = grep(!$clear{$_}, @results);

        return @clearResults;
}

sub CreateResultsHash{
        my @clear = &ClearOutStopwords($_[0]);
        my %results;

foreach my $c (@clear){
        $results{$c}++;
        }
return %results;
}

sub PrintResultsToFile{
        open(SAVE, ">>printedResults.txt");
        (my @files, my @all) = &CollectingResults($_[0]);
        my %results = &CreateResultsHash(@all);
        my @arranged = sort({$results{$a} <=> $results{$b}} keys %results);

        foreach my $f (@files){
                print(SAVE "$f \n");
                }
        foreach my $r (@arranged){
                print(SAVE "$r \t $results{$r} \n");
        }

}

&CollectingResults("./Segunda/*/*");

