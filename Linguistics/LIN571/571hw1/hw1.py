#Tara Edwards

"""
I am doing the code rather slowly. I figure what I need to do is load the sentences, then load the grammar. The split the sentences line-by-line and read them into the parser. Get the best possible tree for each line. Print the parses for each line and add them to a larger number. Get number of lines and divide the total parses by the lines. I find the hard part is figuring if I should tokenize by sentence, then pass on individual sentences into the method, or further tokenize the sentence into words and pass them into the method. At this time, I still do not know. 
"""

def hw1
    import nltk
    from nltk import Nonterminal, nonterminals, Production, parse_cfg, ContextFreeGrammar
    from nltk.parse import EarleyChartParser 
    from __future__ import division
    g = nltk.data.load("file:./grammar.cfg", format='cfg')    
    f = nltk.data.load("file:./sentences.txt", format='raw')
    j = open("./hw1.out", 'w')

    eparser = nltk.parse.EarleyChartParser(g)
    list = nltk.sent_tokenize(f)
    for j in list:
        p = nltk.word_tokenize(j)
        trees = eparser.nbest_parse(p)
        for tree in trees:
             j.write(tree + "\r \n")
             j.write(len(tree.parses(grammar.start())))


   numberofparses = len(trees.parses(grammar.start()))
   sentences_total = len(list)
   j.write(numberofparses/sentences_total)

    close(j)


