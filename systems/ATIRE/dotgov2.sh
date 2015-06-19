#!/bin/bash
set -f

source ../common.sh

GOV2_FILES=$(find $GOV2_LOCATION -mindepth 1 -maxdepth 1 -type d -name 'GX*' -printf '%p/*.gz ')

hg clone http://atire.org/hg/atire -r rigor-2015

cd atire

make USE_PRINT_TIME_NO_CONVERSION=1

stdbuf -oL ./bin/index -N1000000 -sa -rrtrec -iscrub:an -findex index.aspt ${GOV2_FILES[@]} | tee.indexing.txt
stdbuf -oL ./bin/index -N1000000 -sa -rrtrec -iscrub:an -QBM25 -q -findex quantized.aspt ${GOV2_FILES[@]} | tee quantized.indexing.txt

for index in "index.aspt" "quantized.aspt"
do
	for queries in "701-750" "751-800" "801-850"
	do
		query_file=../$TOPICS_QRELS/topics.${queries}.txt
		qrel_file=../$TOPICS_QRELS/qrels.${queries}.txt
		stat_file=${index}.${queries}.search_stats.txt
		run_file=atire.${index}.${queries}.txt
		eval_file=eval.${index}.${queries}.txt

		./bin/atire -findex ${index} -sa -QN:t -k1000 -q ${query_file} -et -l1000 -o${run_file} -iatire > ${index}.${stat_file}
		../$TREC_EVAL ${qrel_file} ${run_file} > ${eval_file}
	done
done
