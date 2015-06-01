#!/bin/bash
set -ef

GOV2_FILES=$(find /media/Gov2/data -mindepth 1 -maxdepth 1 -type d -name 'GX*' -printf '%p/*.gz ')

hg clone http://atire.org/hg/atire

cd atire

make

./bin/index -N1000000 -rrtrec -sa -iscrub:an -QBM25 -q ${GOV2_FILES[@]} | tee -a indexing.txt

for queries in "701-750" "751-800" "801-850"
do
	./bin/atire -sa -QN:t -q ../../../topics-and-qrels/topics.${queries}.txt -et -l1500      -oatire.${queries}.completion.txt -iatire -ncompletion > ${queries}.completion.search_stats.txt
	./bin/atire -sa -QN:t -q ../../../topics-and-qrels/topics.${queries}.txt -et -l1500 -k20 -oatire.${queries}.topk.txt       -iatire -ntop-k      > ${queries}.topk.search_stats.txt
done
