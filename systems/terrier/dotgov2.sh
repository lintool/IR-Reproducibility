#!/bin/bash
set -ef

source ../common.sh

INDEX="noblocks"
#INDEX="classical"
#INDEX="blocks_fields"
#INDEX="blocks"
#INDEX="classical"
#RANKER="DPH"
#RANKER="BM25"
#RANKER="DPH_Prox"
RANKER="DPH_QE"


if [[ ! -f terrier-4.0.tar.gz ]]; then
	curl http://www.dcs.gla.ac.uk/~craigm/terrier-4.0.tar.gz> terrier-4.0.tar.gz
fi
rm -rf terrier-4.0
tar -zxvf terrier-4.0.tar.gz
cd  terrier-4.0

bin/trec_setup.sh $GOV2_LOCATION 2>&1  | tee trec_setup.log
#mv etc/collection.spec collection.spec && head collection.spec > etc/collection.spec

OPTS="-i -j"
if [ "$INDEX" == "classical" ];
then
 OPTS="-i"
fi

echo <<EOF >> etc/terrier.properties
trec.collection.class=TRECWebCollection
#indexer.meta.forward.keys=docno,url
#indexer.meta.forward.keylens=26,256
indexer.meta.forward.keys=docno
indexer.meta.forward.keylens=26
indexer.meta.reverse.keys=
ignore.low.idf.terms=false

#faster indexing with more memory
memory.reserved=104857600
EOF

if [ "$INDEX" == "blocks" ];
then
 OPTS="$OPTS -Dblock.indexing=true"
elif [[ "$INDEX" == "blocks_fields" ]]; then
 OPTS="$OPTS -Dblock.indexing=true -DFieldTags.process=TITLE,ELSE"
fi

JAVA_OPTIONS=-XX:-UseGCOverheadLimit TERRIER_HEAP_MEM=100g bin/trec_terrier.sh $OPTS 2>&1 | tee indexing.log

if [[ "$INDEX" == "blocks_fields" ]]; then
	 perl -pi -e 's/FSADocumentIndex$/FSAFieldDocumentIndex/g' var/index/data.properties
fi



for RANKER in DPH DPH_QE;
do
  ../dotgov2-ranker.sh $INDEX $RANKER
done
