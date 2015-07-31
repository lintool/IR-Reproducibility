#!/bin/bash
set -e

# Runs the MG4J k-out-of-n queries and perform evaluation

source ../common.sh

export CLASSPATH=$(find -iname \*.jar | paste -d: -s)

WORK_DIR=.

for queries in "701-750" "751-800" "801-850"
do
	topics=$TOPICS_QRELS/topics.$queries.txt
	qrels=$TOPICS_QRELS/qrels.$queries.txt
	err=err.$queries.txt
	run=run.$queries.txt

	# Extract titles, minimal massaging (no stopwords, U.S. => U S, etc.)
	fgrep -A1 "<title>" $topics | sed 's/<title>//;s/--//;/^[[:space:]]*$/d;s/[[:space:]]*$//;s/^[[:space:]]*//' | sed "s/-/ /g;s/U.S./U S/;s/'s//" | sed 's/\<\(in\|to\|of\|on\|for\|and\|at\)\>//g' > titles.$queries.txt
	# Generate input files
	cat <(echo -e "\$score BM25Scorer(1.2,0.3)\n\$limit 1000\n\$divert $run\n\$mplex off") <(./genqueries.sh $(echo ${queries%-*}) <titles.$queries.txt) >in.$queries.txt

	java -server it.unimi.di.big.mg4j.query.Query $WORK_DIR/gov2-text -T $WORK_DIR/gov2.titles <in.$queries.txt 2>$err

	$TREC_EVAL -q $qrels $run >eval.$queries.txt

	grep ms\; $err | cut -d' ' -f6 | paste -d+ -s | bc -l >time.$queries.txt
done
