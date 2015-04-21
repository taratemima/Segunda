#!/usr/bin/env perl

## created on 11/8/07, modified from ff193.exec

## Purpose: create a smoothed HMM from the training data.
##  This is for a trigram POS tagger: each state is a POS pair

##  The format of the training data: w1/t1 w2/t2 ... w_n/tn  # no BOS, EOS inserted

##  for each input sentence, we will add "BOS/<s>" and "EOS/</s>"
##   usage: cat training_data | $0 hmm_file l1 l2 l3 {unk_prob}
##


## modification from ff193.exec in order to smooth the trigram model
##   - transition prob is the interpolated P(t3|t1,t2) and P(t|BOS)
##   - emisson prob: add P(<unk>|t)

## N is the size of the tagset (including BOS and EOS)
## M is the number of unique (w,t) pairs, t can be BOS or EOS
## O is the number of entries in unk_prob_file

## the number of states will be N^2
## the number of symbols will be the number of words (including <s> and </s>)
##    plus 1 (for <unk> if unk_prob_file is provided)
## the number of transitions will be N^3 
## the number of emissions will be: MN +ON: ON is for P(<unk>|t)
 

use strict;

my $sent_num = 0;   # non-blank line
my $voc_size = 0;   # without unk
my $token_num = 0;  # number of word types
my $bigram_num = 0;


my $BOS_tag = "BOS";
my $EOS_tag = "EOS";

my $unk_word = "<unk>";
my $BOS_str = "<s>/$BOS_tag"; 
my $EOS_str = "</s>/$EOS_tag";

my $delim = " ";

my $log10 = log(10);

main();

1;


##########################################
sub main {
    if(@ARGV < 4){
	die "usage: cat training_data | $0 hmm l1 l2 l3 {unk_prob} {renormalation_flag}\n";
    }

    my $arg_num = scalar @ARGV;

    #### step 0: read the files
    my $output_hmm = $ARGV[0];
    my $l1 = $ARGV[1];
    my $l2 = $ARGV[2];
    my $l3 = $ARGV[3];
    my $eps = 0.01;

    my $sum = $l1 + $l2 + $l3;
    if(($sum < 1 - $eps) || ($sum > 1 + $eps)){
	print STDERR "warning: lambdas do not add up to one: $l1+$l2+$l3=$sum\n";
    }else{
	print STDERR "l1=$l1, l2=$l2, l3=$l3\n";
    }
 

    my %unk_hash = ();  ## store P(<unk> | t)
    if($arg_num > 4){
	my $unk_file = $ARGV[4];
	my $entry_num = read_unk_prob_file($unk_file, \%unk_hash);
	if($entry_num < 0){
	    die "wrong unknown_prob_file $unk_file\n";
	}else{
	    print STDERR "read $entry_num entries from $unk_file\n";
	}	    
    }

    my $renorm_flag = 1;  ### renorm P(w|t) by multiplying it with 1-P(unk|t)
    if($arg_num > 5){
	$renorm_flag = $ARGV[5];

    }

    print STDERR "renorm_flag=$renorm_flag\n";

    open(my $output_fp, ">$output_hmm") or die "cannot create $output_hmm\n";

    ################# step 1: collect the counts
    my %unigram_hash = ();   # the count of tags, including BOS and EOS
    my %bigram_hash = ();    # the count of bigram tags
    my %trigram_hash = (); 
    my %wt_hash = ();        # the count of (word, tag) pairs
    my %voc = ();            # the count of symbols

    

    my $sent_num = 0;
    my $word_num = 0;  # word type number, w/o EOS/BOS

    my $unigram_N = 0;    # number of unigram tokens
    my $bigram_N = 0;
    my $trigram_N = 0;
    
    my $BOS_bigram_num = 0;  # the number POS tags that can start a sent

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

	    $unigram_N ++;

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
	    my $next_t = $EOS_tag;
	    if($i < $sent_leng-1){
		$next_t = $tags[$i+1];
	    }

	    $bigram_N ++;

	    $key = "$t $next_t";
	    if(defined($bigram_hash{$key})){
		$bigram_hash{$key}++;	
	    }else{
		$bigram_hash{$key} = 1;
		if($i == 1){
		    $BOS_bigram_num ++;
		}
	    }

	    ### trigram
	    my $next2_t = $EOS_tag;
	    if($i < $sent_leng - 2){
		$next2_t = $tags[$i+2];
	    }

	    $trigram_N ++;

	    $key = "$t $next_t $next2_t";
	    if(defined($trigram_hash{$key})){
		$trigram_hash{$key}++;	
	    }else{
		$trigram_hash{$key} = 1;
	    }
	    
	}
    } # end for each sentence


    print STDERR "Finish reading\n sent_num=$sent_num, word_num=$word_num\n";
    my $tag_num = scalar (keys %unigram_hash);
    print STDERR "tag_num=$tag_num\n";
    print STDERR "unigram_N=$unigram_N bigram_N=$bigram_N trigram_N=$trigram_N\n";

    print STDERR "BOS_bigram_num=$BOS_bigram_num\n";

    ######## step 2: dump the hmm model
    dump_smoothed_hmm($output_fp, \%voc, \%unigram_hash, \%bigram_hash,
		      \%trigram_hash, \%wt_hash, \%unk_hash,
		      $unigram_N, $l1, $l2, $l3, $renorm_flag);

    print STDERR "All done. Output is under $output_hmm\n";
}

### P(t3 | t1, t2) = l1 P(t3) + l2 P(t3 | t2) + l3 P(t3 | t1, t2)
### P(w | t) = P(w|t) * (1 - P(unk | t))
###
sub dump_smoothed_hmm {
    my ($output_fp, $voc_ptr, $unigram_ptr, $bigram_ptr, 
	$trigram_ptr, $wt_ptr, $unk_ptr, 
	$unigram_N, $l1, $l2, $l3, $renorm_flag) = @_;

    my @tagset = (sort {$unigram_ptr->{$b} <=> $unigram_ptr->{$a}} 
		  keys %$unigram_ptr);

    dump_header($output_fp, $voc_ptr, $unigram_ptr, $bigram_ptr, 
		$trigram_ptr, $wt_ptr, $unk_ptr);

    print $output_fp "\\transition\n";
    dump_bigram_trans_prob($output_fp, \@tagset, $unigram_ptr, $bigram_ptr, 
			   $unigram_N, $l1, $l2, $l3);

    dump_trigram_trans_prob($output_fp, \@tagset, $unigram_ptr, $bigram_ptr, 
			   $trigram_ptr, $unigram_N, $l1, $l2, $l3);

    dump_emiss_prob($output_fp, \@tagset, $voc_ptr, $unigram_ptr, 
		    $wt_ptr, $unk_ptr, $renorm_flag);

    close($output_fp);
}

sub dump_header {
    my ($output_fp, $voc_ptr, $unigram_ptr, $bigram_ptr, 
	$trigram_ptr, $wt_ptr, $unk_ptr) = @_;

    my $tag_num = scalar (keys %$unigram_ptr); # the tag number including BOS and EOS

    my $state_num = $tag_num * $tag_num;  # 1 for BOS
    my $unk_tag_num = scalar (keys %$unk_ptr);
    my $sym_num = scalar (keys %$voc_ptr);
    
    if($unk_tag_num > 0){
	$sym_num ++;
    }

    my $init_line_num = 1;
    my $trans_line_num = $state_num * $tag_num;


    my $M = scalar (keys %$wt_ptr);
    my $emiss_line_num = ($M+$unk_tag_num) * $tag_num;

    print $output_fp "state_num=$state_num\n";
    print $output_fp "sym_num=$sym_num\n";
    print $output_fp "init_line_num=$init_line_num\n";
    print $output_fp "trans_line_num=$trans_line_num\n";
    print $output_fp "emiss_line_num=$emiss_line_num\n\n\n";

    print $output_fp "\\init\n";
    print $output_fp "$BOS_tag\_$BOS_tag 1.0\n\n\n";
}


### dump P(t|BOS): there are N transitions.
sub dump_bigram_trans_prob {
    my ($output_fp, $tagset, $unigram_ptr, $bigram_ptr, 
	$unigram_N, $l1, $l2, $l3) = @_;


    ##### step 1:  print P(t1 | BOS)
    my $sent_num = $unigram_ptr->{$BOS_tag};
    if(!defined($sent_num)){
	die "BOS freq is not defined\n";
    }

    my $tag_num = scalar @$tagset;

    for my $t (@$tagset){
	# if($t eq $BOS_tag || $t eq $EOS_tag){
	#    next;
	#}

	my $key2 = "$BOS_tag $t";
	my $cnt2 = get_ngram_cnt($bigram_ptr, $key2);
	
	my $p2 = div_result($cnt2, $sent_num, 0); # p2=P(t|BOS)

	my $cnt1 = get_ngram_cnt($unigram_ptr, $t);
	my $p1 = div_result($cnt1, $unigram_N, 0); # p1=P(t)

	my $p = ($l2+$l3) * $p2 + $l1 * $p1;
        if($p > 0){
	    my $logprob = log($p)/$log10;
	    print $output_fp "$BOS_tag\_$BOS_tag\t$BOS_tag\_$t\t$p\t$logprob\t\#\# p2=$cnt2/$sent_num=$p2 p1=$cnt1/$unigram_N=$p1\n";
        }
    }    
}


# if num2 == 0 then return default
#   else return $num1/$num2
sub div_result {
    my ($num1, $num2, $default) = @_;
    if($num2){
	return $num1/$num2;
    }else{
	return $default;
    }
}

sub get_ngram_cnt {
    my ($hash, $key) = @_;
    my $cnt = $hash->{$key};
    if(defined($cnt)){
	return $cnt;
    }else{
	return 0;
    }
}


##### print out "t1_t2 t2_t3 P(t3 | t1, t2): N^3 + 2N^2 lines
sub dump_trigram_trans_prob {
    my ($output_fp, $tagset, $unigram_ptr, $bigram_ptr, $trigram_ptr,
	$unigram_N, $l1, $l2, $l3) = @_;
    

    my $tag_num = scalar @$tagset;

    foreach my $t1 (@$tagset){
	## if($t1 eq $EOS_tag){
	##    next;
	## }

	foreach my $t2 (@$tagset){
	    ## if($t2 eq $EOS_tag || $t2 eq $BOS_tag){
	    ##	next;
	    ## }

	    my $t2_cnt = get_ngram_cnt($unigram_ptr, $t2);
	    
	    if(($t1 eq $BOS_tag) && ($t2 eq $BOS_tag)){
		# P(t | BOS, BOS) is estimated as P(t|BOS)
                #  and it has been output already.
		next;
	    }

	    foreach my $t3 (@$tagset){
		## if($t3 eq $BOS_tag){
		##    next;
		## }

		############ calc p3
		my $key = "$t1 $t2 $t3";
		my $t1_t2_t3_cnt = get_ngram_cnt($trigram_ptr, $key);
		
		$key = "$t1 $t2";
		my $t1_t2_cnt = get_ngram_cnt($bigram_ptr, $key);

		my $p3 = div_result($t1_t2_t3_cnt, $t1_t2_cnt, 1/$tag_num);
		
		########### calc p2
		$key = "$t2 $t3";
		my $t2_t3_cnt = get_ngram_cnt($bigram_ptr, $key);

		my $p2 = div_result($t2_t3_cnt, $t2_cnt, 0);

		########### calc p1
		my $t3_cnt = get_ngram_cnt($unigram_ptr, $t3);
		my $p1 = div_result($t3_cnt, $unigram_N, 0);

		my $p = $l1 * $p1 + $l2 * $p2 + $l3 * $p3;
                if($p > 0){
		    my $logprob = log($p)/$log10;
		    print $output_fp "$t1\_$t2\t$t2\_$t3\t$p\t$logprob\t\#\# p3=$t1_t2_t3_cnt/$t1_t2_cnt=$p3 p2=$t2_t3_cnt/$t2_cnt=$p2 p1=$t3_cnt/$unigram_N=$p1\n";
                }
	    }
	}
    }
}



sub dump_emiss_prob {
    my ($output_fp, $tagset, $voc_ptr, $unigram_ptr, $wt_ptr, $unk_ptr,
	$renorm_flag) = @_;
    
    print STDERR "dumping emiss prob: renorm_flag=$renorm_flag\n";


    print $output_fp "\n\n\\emission\n";
    
    for my $key (sort keys %$wt_ptr){
	my $cnt = $wt_ptr->{$key};
	my @parts = split(/\s+/, $key);
	if(scalar @parts != 2){
	    print STDERR "wrong (word, tag) pair: +$key+\n";
	    next;
	}
	my $w = $parts[0];
	my $t = $parts[1];
	my $cnt1 = $unigram_ptr->{$t};
	if(!defined($cnt1)){
	    print STDERR "wrong unigram key: +$t+\n";
	}

	my $prob = $cnt/$cnt1;

	my $val = 0;
	if($renorm_flag > 0){
	    $val = $unk_ptr->{$t};
	    if(!defined($val)){
		$val = 0;
	    }
	}

	## my $new_prob = $prob/(1+$val);
	my $new_prob = $prob * (1-$val);

	if($new_prob > 0){
	    my $logprob = log($new_prob)/$log10;

	    foreach my $t1 (@$tagset){
		print $output_fp "$t1\_$t\t$w\t$new_prob\t$logprob\t\#\# $cnt/$cnt1=$prob unk=$val\n";
	    }
	}
    }

    ### print out P(<unk>|t): O(N+1) entries
    for my $t (sort keys %$unk_ptr){
	my $prob = $unk_ptr->{$t};
	foreach my $t1 (@$tagset){
	    print $output_fp "$t1\_$t\t$unk_word\t$prob\n";
	}
    }

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


sub read_unk_prob_file {
    my ($file_name, $hash_ptr) = @_;

    open(my $fp, "$file_name") or die "cannot open $file_name\n";

    my $res = 0;
    while(<$fp>){
	chomp;
	if(/^\s*$/){
	    next;
	}
	my @parts = split(/\s+/);
	if(scalar @parts < 2){
	    print STDERR "wrong format in $file_name: +$_+\n";
	    next;
	}

	my $t = $parts[0];
	my $p = $parts[1];
	if($p > 1 || $p <= 0){
	    print STDERR "wrong format in $file_name: p=$p +$_+\n";
	    next;
	}

	$hash_ptr->{$t} = $p;
	$res ++;
    }

    return $res;
}
