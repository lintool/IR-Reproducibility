#!/bin/bash
set -ex

# Plain BM25 on disjunctive queries (mainly as a baseline)

source ../common.sh

export CLASSPATH=$(find -iname \*.jar | paste -d: -s)

WORK_DIR=.

for queries in "701-750" "751-800" "801-850"
do
	topics=$TOPICS_QRELS/topics.$queries.txt
	qrels=$TOPICS_QRELS/qrels.$queries.txt
	err=err-bm25.$queries.txt
	run=run-bm25.$queries.txt

	# Extract titles, minimal massaging (no stopwords, U.S. => U S, etc.)
	fgrep -A1 "<title>" $topics | sed 's/<title>//;s/--//;/^[[:space:]]*$/d;s/[[:space:]]*$//;s/^[[:space:]]*//' | sed "s/-/ /g;s/U.S./U S/;s/'s//" | sed 's/\<\(in\|to\|of\|on\|for\|and\|at\)\>//g' > titles.$queries.txt
	# Generate input files
	cat <(echo -e "\$score BM25Scorer(1.2,0.3)\n\$limit 1000\n\$divert $run\n\$mplex off") <(sed -e 's/[ ]\+/|/g' <titles.$queries.txt | awk "BEGIN {i = ${queries%-*} } { print \"\$mode trec \" i \" mg4jAuto\"; print; i = i + 1; }" ) >in-bm25.$queries.txt

	java -server it.unimi.di.big.mg4j.query.Query $WORK_DIR/gov2-text -T $WORK_DIR/gov2.titles <in-bm25.$queries.txt 2>$err

	./trec_eval $qrels $run >eval-bm25.$queries.txt

	grep ms\; $err | cut -d' ' -f6 | paste -d+ -s | bc -l >time-bm25.$queries.txt
done
