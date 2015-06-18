import sys, json

operator = sys.argv[1]
queries = []
inTopic = False
number=None
query = None
with open(sys.argv[2]) as fp:
    for line in fp:

        if not inTopic:
            if line.startswith('<top>'):
                inTopic = True
            continue
        # inTopic=True
        if line.startswith('</top>'):
            terms = ['#dirichlet(%s)' % x for x in query.split()]
            queries += [{
                'number': number, 
                'text': '#'+operator+'('+' '.join(terms)+')'
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
