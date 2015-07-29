#!/bin/bash

source ../common.sh
source setup.sh

if [[ ! -f ../${ATIRE_DIR}/dg2_quantized.aspt ]]; then
	echo "Must have built an ATIRE quantized index"
	echo "Looked for: ../${ATIRE_DIR}/dg2_quantized.aspt"
	exit
fi

START=$(date +%s)
./atire_to_jass_index ../${ATIRE_DIR}/dg2_quantized.aspt -Q
END=$(date +%s)

echo "'Indexing' took:" $((END - START)) "seconds"

for queries in "701-750" "751-800" "801-850"
do
	query_file=../$TOPICS_QRELS/topics.web.${queries}.txt
	qrel_file=../$TOPICS_QRELS/qrels.web.${queries}.txt
	stat_file=${index}.${queries}.search_stats.txt
	run_file=${queries}.txt
	eval_file=eval.${queries}.txt

	./trec2query/trec2query ${query_file} q > ${queries}.txt

	echo "Searching queries ${queries} to 1B postings"
	./jass ${queries}.txt 1000 1000000000 -d > comp.${stat_file}
	mv ranking.txt comp.jass.${run_file}
	../$TREC_EVAL ${qrel_file} comp.jass.${run_file} > comp.${eval_file}

	echo "Searching queries ${queries} to 2.5M postings"
	./jass ${queries}.txt 1000 2500000 -d > heur.${stat_file}
	mv ranking.txt heur.jass.${run_file}
	../$TREC_EVAL ${qrel_file} heur.jass.${run_file} > heur.${eval_file}
done
