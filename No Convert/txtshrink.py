import string
import sys

def main():
    # get some stop words
    stopf = open('stop_words.txt', "r")
    stopwords = {}
    for s in stopf:
        stopwords[string.strip(s)] = 1

    file = open(sys.argv[1], "r")
    filedata = file.read()
    words=string.split(filedata)
    histogram = {}
    count = 0
    for word in words:
        word = string.strip(word, string.punctuation)
        word = string.lower(word)
        if word in stopwords:
            continue
        histogram[word] = histogram.get(word, 0) + 1
        count = (count+1) % 1000
        if count == 0:
            print '*',
    flist = []
    for word, count in histogram.items():
        flist.append([count, word])
    flist.sort()
    flist.reverse()
    shrinkfile = open('output.txt', 'w')
    for pair in flist[0:100]:
        shrinkfile.write((pair[1] + " ")*(pair[0]/10))
        print "%30s: %4d" % (pair[1], pair[0])
    shrinkfile.close()
          
main()
