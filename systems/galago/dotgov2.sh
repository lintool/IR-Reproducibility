#!/bin/bash
set -ef

source ../common.sh

HACKDIR='galago-5.7-bin' # galago 3.7 was part of Lemur 5.7

if [[ ! -f galago-3.7.tar.gz ]]; then
  wget http://sourceforge.net/projects/lemur/files/lemur/galago-3.7/galago-3.7-bin.tar.gz/download -O galago-3.7.tar.gz
fi

tar -xf galago-3.7.tar.gz
mv galago-5.7-bin galago-3.7
cd galago-3.7

export JAVA_OPTS='-Xmx6g -ea'
chmod +x bin/galago
GALAGO='java -jar '

bin/galago build --inputPath=${GOV2_LOCATION} --indexPath=gov2.galago | tee build_index.log

#for queries in "701-750" "751-800" "801-850"
#do
#	query_file=../$TOPICS_QRELS/topics.${queries}.txt
#	qrel_file=../$TOPICS_QRELS/qrels.${queries}.txt
#	stat_file=${queries}.search_stats.txt
#	run_file=$PWD/terrier.${queries}.txt
#
#	TERRIER_HEAP_MEM=26g bin/trec_terrier.sh -r -Dtrec.topics=$query_file -Dtrec.results.file=$run_file > $stat_file 2>&1
#
#	../$TREC_EVAL ${qrel_file} ${run_file}
#
#	#grep 'Total Time to Search' ${stat_file} | sed \$d
#done
