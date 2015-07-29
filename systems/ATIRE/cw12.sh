#!/bin/bash
set -e

source ../common.sh
source setup.sh

set +o noglob
CW12B_FILES=$(find $CW12B_LOCATION/ClueWeb* -mindepth 1 -maxdepth 1 -type d -printf '%p/*.gz ')
set -o noglob

BASE_INDEX="stdbuf -oL ./bin/index -N1000000 -sa -rrwarcgz -iscrub:un -kt"
${BASE_INDEX} -findex cw12_index.aspt ${CW12B_FILES[@]} | tee cw12_indexing.txt
${BASE_INDEX} -QBM25 -q -findex cw12_quantized.aspt ${CW12B_FILES[@]} | tee cw12_quantized.indexing.txt

for index in "cw12_index.aspt" "cw12_quantized.aspt"
do
	for queries in "201-250" "251-300"
	do
		query_file=../$TOPICS_QRELS/topics.web.${queries}.txt
		qrel_file=../$TOPICS_QRELS/qrels.web.${queries}.txt
		stat_file=${index}.${queries}.search_stats.txt
		run_file=atire.${index}.${queries}.txt
		eval_file=eval.${index}.${queries}.txt

		echo "Searching queries ${queries} on index ${index}"
		./bin/atire -findex ${index} -sa -QN:q -k1000 -q ${query_file} -et -l1000 -o${run_file} -iatire > ${stat_file}
		../${TREC_EVAL} ${qrel_file} ${run_file} > ${eval_file}
		../${GD_EVAL} -c -traditional ${qrel_file} ${run_file} >> ${eval_file}
	done
done
