import sys, json

operator = sys.argv[1]
queries = []
inTopic = False
number=None
query = None

def makeCombineQuery(query):
    terms = ['#dirichlet(%s)' % x for x in query.split()]
    return '#combine('+' '.join(terms)+')'

def makeSDMQuery(query):
    return '#sdm('+' '.join(query.split())+')'

with open(sys.argv[2]) as fp:
    for line in fp:

        if not inTopic:
            if line.startswith('<top>'):
                inTopic = True
            continue
        # inTopic=True
        if line.startswith('</top>'):
            if operator == 'combine':
                queries += [{ 'number': number, 'text': makeCombineQuery(query) }]
            elif operator=='sdm':
                queries += [{ 'number': number, 'text': makeSDMQuery(query) }]
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
