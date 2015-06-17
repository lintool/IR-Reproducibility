#!/bin/bash
set -efu

source ../common.sh

GALAGO='galago-3.8alpha'
URL="http://ciir.cs.umass.edu/~jfoley/${GALAGO}.tar.gz"
TMPDIR="tmp/"

if [[ ! -f ${GALAGO}.tar.gz ]]; then
  wget ${URL} -O ${GALAGO}.tar.gz
fi

if [[ ! -f ${GALAGO}/bin/galago ]]; then
  rm -rf ${GALAGO}
  tar -xf ${GALAGO}.tar.gz
fi

cd ${GALAGO}


mkdir -p ${TMPDIR}
export JAVA_OPTS="-Djava.io.tmpdir=${TMPDIR} -Xmx7g -ea"
chmod +x bin/galago

# build index if not already:
INDEX_PATH=gov2.galago
LOG_FILE=build_index.log

if [[ ! -f ${INDEX_PATH}/buildManifest.json ]]; then
  bin/galago build --mode=fork --distrib=16 --filetype=trecweb --nonStemmedPostings=false --stemmedPostings=false --stemmedCounts=true --corpus=false --inputPath=${GOV2_LOCATION} --indexPath=${INDEX_PATH} 2>&1 > ${LOG_FILE}
fi

rm -rf ${TMPDIR} # remove any lingering temporary files

for queries in "701-750" "751-800" "801-850"
do
  query_file=../$TOPICS_QRELS/topics.${queries}.txt
  qrel_file=../$TOPICS_QRELS/qrels.${queries}.txt
  query_json=q${queries}.json
  python2 ../make_query_json.py combine $query_file > $query_json # generate title queries
  run_file=galago${queries}.trecrun
  
  if [[ ! -f ${run_file} ]]; then
    bin/galago batch-search ${query_json} --requested=1000 --index=${INDEX_PATH} > ${run_file}
  fi
  ../$TREC_EVAL ${qrel_file} ${run_file} > galago${queries}.treceval
done

