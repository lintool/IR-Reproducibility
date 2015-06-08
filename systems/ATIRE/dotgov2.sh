#!/bin/bash
set -ef

source ../common.sh

GOV2_FILES=$(find $GOV2_LOCATION -mindepth 1 -maxdepth 1 -type d -name 'GX*' -printf '%p/*.gz ')


hg clone http://atire.org/hg/atire

cd atire

make USE_PRINT_TIME_NO_CONVERSION=1

#./bin/index -N1000000 -sa -rrtrec -iscrub:an -ts -QBM25 -q -findex quantized.aspt ${GOV2_FILES[@]} | tee quantized.indexing.txt
./bin/index -N1000000 -sa -rrtrec -iscrub:an -ts ${GOV2_FILES[@]} | tee indexing.txt

for queries in "701-750" "751-800" "801-850"
do
	query_file=../$TOPICS_QRELS/topics.${queries}.txt
	qrel_file=../$TOPICS_QRELS/qrels.${queries}.txt
	stat_file=${queries}.search_stats.txt
	run_file=atire.${queries}.txt

	#./bin/atire -findex quantized.aspt -M -sa -QN:t -q ${query_file} -et -l1000 -oatire.${queries}.speed.txt -iatire -nquantized > ${queries}.speed.search_stats.txt
	./bin/atire -Qr -sa -QN:t -q ${query_file} -et -l1000 -o${run_file} -iatire > ${stat_file}
	../$TREC_EVAL ${qrel_file} ${run_file}

	#grep 'Total Time to Search' ${stat_file} | sed \$d
done