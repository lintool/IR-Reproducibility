#!/bin/bash
set -ef

GOV2_FILES=$(find /media/Gov2/data -mindepth 1 -maxdepth 1 -type d -name 'GX*' -printf '%p/*.gz ')

hg clone http://atire.org/hg/atire

cd atire

make

./bin/index -N1000000 -sa -rrtrec -iscrub:an -ts -QBM25 -q -findex quantized.aspt ${GOV2_FILES[@]} | tee quantized.indexing.txt
./bin/index -N1000000 -sa -rrtrec -iscrub:an -ts ${GOV2_FILES[@]} | tee indexing.txt

for queries in "701-750" "751-800" "801-850"
do
	./bin/atire -findex quantized.aspt -M -sa -QN:t -q ../../../topics-and-qrels/topics.${queries}.txt -et -l1000 -oatire.${queries}.speed.txt -iatire -nquantized > ${queries}.speed.search_stats.txt
	./bin/atire -Qr -sa -QN:t -q ../../../topics-and-qrels/topics.${queries}.txt -et -l1000 -oatire.${queries}.unquantized.txt -iatire -nunquantized > ${queries}.precision.search_stats.txt
done
