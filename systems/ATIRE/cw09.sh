#!/bin/bash
set -ef

source ../common.sh
source setup.sh

CW09B_FILES=$(find $CW09B_LOCATION -mindepth 1 -maxdepth 1 -type d -printf '%p/*.warc.gz ')

BASE_INDEX="stdbuf -oL ./bin/index -N1000000 -sa -rrwarcgz -iscrub:un -kt"
${BASE_INDEX} -findex cw09_index.aspt ${CW09B_FILES[@]} | tee cw09_indexing.txt
${BASE_INDEX} -QBM25 -q -findex cw09_quantized.aspt ${CW09B_FILES[@]} | tee cw09_quantized.indexing.txt

for index in "cw09_index.aspt" "cw09_quantized.aspt"
do
	for queries in "51-100" "101-150" "151-200"
	do
		query_file=../$TOPICS_QRELS/topics.web.${queries}.txt
		qrel_file=../$TOPICS_QRELS/qrels.web.${queries}.txt
		stat_file=${index}.${queries}.search_stats.txt
		run_file=atire.${index}.${queries}.txt
		eval_file=eval.${index}.${queries}.txt

		echo "Searching queries ${queries} on index ${index}"
		./bin/atire -findex ${index} -sa -QN:q -k1000 -q ${query_file} -et -l1000 -o${run_file} -iatire > ${stat_file}
		../$TREC_EVAL ${qrel_file} ${run_file} > ${eval_file}
	done
done
