#!/bin/bash
set -ef

source ../common.sh

curl http://www.dcs.gla.ac.uk/~craigm/terrier-4.0.tar.gz
tar -zxvf terrier-4.0.tar.gz
cd  terrier-4.0

make USE_PRINT_TIME_NO_CONVERSION=1

bin/trec_setup.sh share/test/ 2>&1  | tee trec_setup.log
find $GOV2_LOCATION -mindepth 1 -maxdepth 1 -type d -name 'GX*' -printf '%p/*.gz ' > etc/collection.spec
bin/trec_terrier.sh -i -j 2>&1 | tee trec_setup.log

echo <<EOF >> etc/terrier.properties
trec.collection.class=TRECWebCollection
#indexer.meta.forward.keys=docno,url
#indexer.meta.forward.keylens=26,256
indexer.meta.forward.keys=docno
indexer.meta.forward.keylens=26
indexer.meta.reverse.keys=
EOF

for queries in "701-750" "751-800" "801-850"
do
	query_file=../$TOPICS_QRELS/topics.${queries}.txt
	qrel_file=../$TOPICS_QRELS/qrels.${queries}.txt
	stat_file=${queries}.search_stats.txt
	run_file=$PWD/terrier.${queries}.txt

	bin/trec_terrier.sh -r -Dtrec.topics=$query_file -Dtrec.results.file=$run_file > $stat_file 2>&1

	../$TREC_EVAL ${qrel_file} ${run_file}

	#grep 'Total Time to Search' ${stat_file} | sed \$d
done
