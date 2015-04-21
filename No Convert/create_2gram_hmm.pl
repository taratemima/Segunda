#!/usr/bin/env perl

## created on 11/6/07

## Purpose: create HMM from the training data.
##  This is for bigram POS tagger:
##    each state is a POS tag

##  The format of the training data: w1/t1 w2/t2 ... w_n/tn  # no BOS, EOS inserted

##  for each input sentence, we will add "BOS/<s>" and "EOS/</s>"
##  usage: cat training_data | $0 hmm_file
##


use strict;

my $sent_num = 0;   # non-blank line
my $voc_size = 0;   # without EOS, BOS, unk
my $token_num = 0;  # number of word types
my $bigram_num = 0;


my $BOS_str = "<s>/BOS"; 
my $EOS_str = "</s>/EOS";

my $BOS_tag = "BOS";

my $delim = " ";

my $log10 = log(10);

main();

1;


##########################################
sub main {
    if(@ARGV != 1){
	die "usage: cat training_data | $0 hmm\n";
    }

    my $output_hmm = $ARGV[0];

    open(my $output_fp, ">$output_hmm") or die "cannot create $output_hmm\n";

    my %unigram_hash = ();   # the count of tags
    my %bigram_hash = ();    # the count of bigram tags
    my %wt_hash = ();        # the count of (word, tag) pairs
    my %voc = ();            # the count of symbols

    
    ################# step 1: collect the counts
    my $sent_num = 0;
    my $word_num = 0;  # word type number, w/o EOS/BOS

    while(<STDIN>){
	if(/^\s*$/){
	    next;
	}

	s/^\s+//;
	s/\s+$//;

	my $line = $_;
	$line = $BOS_str . " " . $line . " " . $EOS_str;

	$sent_num ++;

	my @words = ();
	my @tags = ();
	my $sent_leng = split_into_wt_pairs($line, \@words, \@tags);
	$word_num += $sent_leng - 2;

	if($sent_leng <= 0){
	    print STDERR "+$line+ has $sent_leng words\n";
	}

	### collect the counts
	for(my $i=0; $i<$sent_leng; $i++){
	    my $w = $words[$i];
	    my $t = $tags[$i];
	    
	    ### unigram
	    if(defined($unigram_hash{$t})){
		$unigram_hash{$t} ++;
	    }else{
		$unigram_hash{$t} = 1;
	    }

	    ## (word, tag) pair
	    my $key = "$w $t";
	    if(defined($wt_hash{$key})){
		$wt_hash{$key} ++;
	    }else{
		$wt_hash{$key} = 1;
	    }

	    ## word
	    if(defined($voc{$w})){
		$voc{$w} ++;
	    }else{
		$voc{$w} = 1;
	    }

	    ### bigram
	    if($i == $sent_leng-1){
		next;
	    }

	    my $next_t = $tags[$i+1];
	    $key = "$t $next_t";
	    if(defined($bigram_hash{$key})){
		$bigram_hash{$key}++;	
	    }else{
		$bigram_hash{$key} = 1;
	    }
	}
    } # end for each sentence


    print STDERR "Finish reading\n sent_num=$sent_num, word_num=$word_num\n";
    
    ######## step 2: dump the hmm model

    ####### 2(a): print out header 
    my $state_num = scalar (keys %unigram_hash);
    my $sym_num = scalar (keys %voc);

    my $init_line_num = 1;
    my $trans_line_num = scalar (keys %bigram_hash);
    my $emiss_line_num = scalar (keys %wt_hash);

    print $output_fp "state_num=$state_num\n";
    print $output_fp "sym_num=$sym_num\n";
    print $output_fp "init_line_num=$init_line_num\n";
    print $output_fp "trans_line_num=$trans_line_num\n";
    print $output_fp "emiss_line_num=$emiss_line_num\n\n\n";


    print $output_fp "\\init\n";
    print $output_fp "$BOS_tag 1.0\n\n\n";

    ### 2(a): print transition prob
    print $output_fp "\\transition\n";

    for my $key (sort keys %bigram_hash){
	my $cnt = $bigram_hash{$key};
	my @parts = split(/\s+/, $key);
	if(scalar @parts != 2){
	    print STDERR "wrong bigram key: +$key+\n";
	    next;
	}
	my $t1 = $parts[0];
	my $t2 = $parts[1];
	my $cnt1 = $unigram_hash{$t1};
	if(!defined($cnt1)){
	    print STDERR "wrong unigram key: +$t1+\n";
	    next;
	}
	
	my $prob = $cnt/$cnt1;
	my $logprob = log($prob)/$log10;

	print $output_fp "$t1\t$t2\t$prob\t$logprob\t\#\# $cnt/$cnt1\n";
    }


    ### 2(b): print emission prob
    print $output_fp "\n\n\\emission\n";
    
    for my $key (sort keys %wt_hash){
	my $cnt = $wt_hash{$key};
	my @parts = split(/\s+/, $key);
	if(scalar @parts != 2){
	    print STDERR "wrong (word, tag) pair: +$key+\n";
	    next;
	}
	my $w = $parts[0];
	my $t = $parts[1];
	my $cnt1 = $unigram_hash{$t};
	if(!defined($cnt1)){
	    print STDERR "wrong unigram key: +$t+\n";
	    next;
	}

	my $prob = $cnt/$cnt1;
	my $logprob = log($prob)/$log10;
	print $output_fp "$t\t$w\t$prob\t$logprob\t\#\# $cnt/$cnt1\n";
    }

    close($output_fp);

    print STDERR "All done. Output is under $output_hmm\n";
}


# return the sent leng or -1 if failed.
sub split_into_wt_pairs {
    my ($line, $word_ptr, $tag_ptr) = @_;
    
    @$word_ptr = ();
    @$tag_ptr = ();

    my @parts = split(/\s+/, $line);
    foreach my $part (@parts){
	if($part =~ /^(.+)\/(.+)$/){
	    my $w = $1;
	    my $t = $2;
	    push(@$word_ptr, $w);
	    push(@$tag_ptr, $t);
	}else{
	    print STDERR "wrong format: +$part+\n";
	}
    }

    my $num = scalar @$word_ptr;
    return $num;
}


sub systemx {
    my ($cmd) = @_;

    print STDERR "\n\n***************$cmd\n\n";
    system($cmd);
    if($?){
        die "$cmd failed\n";
    }else{
        print STDERR "+++++$cmd++++ succeeds\n\n\n";
    }
}
