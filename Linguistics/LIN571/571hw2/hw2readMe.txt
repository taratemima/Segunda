Tara Edwards

I couldn't find settings for convertings context-free grammars into Chomsky normal form, so I wrote my own. Or at least, it was intended to do that. Since it is on warning, it stopped around line 185, since there was an unintialized variable. Which one it was, the error message would not tell me. 

I did the code about two to six hours each day, except for Saturday and Sunday of MLK weekend. Or was it last weekend? Let's say that I spent more time on it on weekdays than on weekends. It made for a grand total of ten days of work. 

I did the scanner/predictor work by distinguishing between terminal words, non-terminals that were both producers and products (that is, found in both A and B pats of CFG), and non-terminal statements that did not belong to either category. It was to fill the table from the bottom-up (from words to tags), and test it from top-down (did the tags go where expected in the sentence, and did they act as expected). I did enforce some order by having the sentences determine what non-terminals were added.

Whether they did add them in order, I am not sure. I think conditions for a split may have made an 'odd number of elements', to paraphrase the error message. However, I am not sure in which split statement. 