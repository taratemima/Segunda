#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;
use Text::CSV;

#From perlmeme.org, adapted from a lot of things

sub FindText{
(my $file, my $keyword) =@_;
        my $csv = Text::CSV->new();
        open(CSV, "<", $file) || die $!;

        while(<CSV>){
                if($csv->parse($_)){
                        my @columns = $csv->fields();
                        my @viable = grep(/$keyword/, @columns);
                        print "@viable \n";
                        }
                        else{
                                my $err = $csv->error_input;
                                print "Failed to parse line: $err \n";
                }
        }


close CSV;
}