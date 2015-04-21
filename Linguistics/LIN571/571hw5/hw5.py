#Tara Edwards

import nltk


grammar = nltk.data.load('file:./grammar.fcfg',format='fcfg')
sentences = nltk.data.load('file:./sentences.txt',format='raw')

f = open('./results.txt', 'w')

for results in nltk.batch_interpret(sentences, grammar):
    for (synrep, semrep) in results:
        f.write(synrep) 
       
