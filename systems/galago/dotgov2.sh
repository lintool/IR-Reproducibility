#!/bin/bash
set -efu

source ../common.sh

HACKDIR='galago-5.7-bin' # galago 3.7 was part of Lemur 5.7

if [[ ! -f galago-3.7.tar.gz ]]; then
  wget http://sourceforge.net/projects/lemur/files/lemur/galago-3.7/galago-3.7-bin.tar.gz/download -O galago-3.7.tar.gz
fi

if [[ ! -f galago-3.7/bin/galago ]]; then
  rm -rf galago-3.7
  tar -xf galago-3.7.tar.gz
  mv ${HACKDIR} galago-3.7
fi

cd galago-3.7
export JAVA_OPTS='-Xmx100g -ea'
chmod +x bin/galago

# build index if not already:
if [[ ! -f gov2.galago/buildManifest.json ]]; then
  bin/galago build \
    --mode=threaded\
    --distrib=16 \
    --filetype=trecweb \
    --nonStemmedPostings=false \
    --corpus=false \
    --galagoJobDir=gov2.gjd \
    --inputPath=${GOV2_LOCATION} \
    --indexPath=gov2.galago | tee build_index.log
fi

for queries in "701-750" "751-800" "801-850"
do
	query_file=../$TOPICS_QRELS/topics.${queries}.txt
	qrel_file=../$TOPICS_QRELS/qrels.${queries}.txt
  query_json=q${queries}.json
  python2 ../make_query_json.py $query_file > $query_json # generate title queries
	run_file=galago${queries}.trecrun

  bin/galago batch-search ${query_json} --requested=1000 --index=gov2.galago > ${run_file}
	../$TREC_EVAL ${qrel_file} ${run_file} > galago${queries}.treceval
done
