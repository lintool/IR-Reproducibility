#!/bin/bash
set -ef

source ../common.sh

hg clone http://www.atire.org/hg/atire -r rigor2015

cd atire

make clean all

GOV2_FILES=$(find $GOV2_LOCATION -mindepth 1 -maxdepth 1 -type d -name 'GX*' -printf '%p/*.gz ')

BASE_INDEX="stdbuf -oL ./bin/index -N1000000 -sa -rrtrec -iscrub:an -ts -kt"
${BASE_INDEX} -findex index.aspt ${GOV2_FILES[@]} | tee indexing.txt
${BASE_INDEX} -QBM25 -q -findex quantized.aspt ${GOV2_FILES[@]} | tee quantized.indexing.txt

for index in "index.aspt" "quantized.aspt"
do
	for queries in "701-750" "751-800" "801-850"
	do
		query_file=../$TOPICS_QRELS/topics.${queries}.txt
		qrel_file=../$TOPICS_QRELS/qrels.${queries}.txt
		stat_file=${index}.${queries}.search_stats.txt
		run_file=atire.${index}.${queries}.txt
		eval_file=eval.${index}.${queries}.txt

		echo "Searching queries ${queries} on index ${index}"
		./bin/atire -findex ${index} -sa -QN:t -k1000 -q ${query_file} -et -l1000 -o${run_file} -iatire > ${stat_file}
		../$TREC_EVAL ${qrel_file} ${run_file} > ${eval_file}
	done
done
