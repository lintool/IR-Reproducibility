#!/bin/bash
set -ef

source ../common.sh

if [[ ! -f terrier-4.0.tar.gz ]]; then
	curl http://www.dcs.gla.ac.uk/~craigm/terrier-4.0.tar.gz> terrier-4.0.tar.gz
fi
rm -rf terrier-4.0
tar -zxvf terrier-4.0.tar.gz
cd  terrier-4.0

bin/trec_setup.sh $GOV2_LOCATION 2>&1  | tee trec_setup.log
#mv etc/collection.spec collection.spec && head collection.spec > etc/collection.spec
TERRIER_HEAP_MEM=26g bin/trec_terrier.sh -i -j 2>&1 | tee trec_setup.log

echo <<EOF >> etc/terrier.properties
trec.collection.class=TRECWebCollection
#indexer.meta.forward.keys=docno,url
#indexer.meta.forward.keylens=26,256
indexer.meta.forward.keys=docno
indexer.meta.forward.keylens=26
indexer.meta.reverse.keys=
ignore.low.idf.terms=false
trec.model=DPH
EOF

for queries in "701-750" "751-800" "801-850"
do
	query_file=../$TOPICS_QRELS/topics.${queries}.txt
	qrel_file=../$TOPICS_QRELS/qrels.${queries}.txt
	stat_file=${queries}.search_stats.txt
	run_file=$PWD/terrier.${queries}.txt

	TERRIER_HEAP_MEM=26g bin/trec_terrier.sh -r -Dtrec.topics=$query_file -Dtrec.results.file=$run_file > $stat_file 2>&1

	../$TREC_EVAL ${qrel_file} ${run_file}

	#grep 'Total Time to Search' ${stat_file} | sed \$d
done
