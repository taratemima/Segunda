#Tara Edwards
#Sanghoun revised this file.
#I revised it again


import nltk
from nltk import Nonterminal, nonterminals, Production, parse_cfg, ContextFreeGrammar, FeatStruct, grammar, parse
from nltk.parse import FeatureEarleyChartParser
from nltk.sem.logic import Variable, VariableExpression, LogicParser

g = nltk.data.load("file:./grammar.fcfg", format='fcfg')    
f = nltk.data.load("file:./feature_sentences.txt", format='raw')

gram = grammar.parse_fcfg(g)
fparser = nltk.parse.FeatureEarleyChartParser(gram)
lines = nltk.sent_tokenize(f)
for line in lines:
	p = nltk.word_tokenize(line)
	trees = fparser.nbest_parse(p)
	for tree in trees:
		print tree
	
		
