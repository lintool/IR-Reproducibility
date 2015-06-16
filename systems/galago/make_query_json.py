import sys, json

queries = []
inTopic = False
number=None
query = None
with open(sys.argv[1]) as fp:
    for line in fp:

        if not inTopic:
            if line.startswith('<top>'):
                inTopic = True
            continue
        # inTopic=True
        if line.startswith('</top>'):
            queries += [{
                'number': number, 
                'text': '#sdm('+query.lower()+')'
                }]
            inTopic = False
            continue
        if line.startswith('<num>'):
            number = line.split('Number: ')[1].strip()
        if line.startswith('<title>'):
            query = line[len('<title>'):].strip().replace(".", "")
            if not query:
                query = next(fp).strip().replace(".","")
        #print line;

queries_json = {'queries': queries}
print json.dumps(queries_json)
