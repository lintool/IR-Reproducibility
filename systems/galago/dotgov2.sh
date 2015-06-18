#!/bin/bash
set -efu

source ../common.sh

GALAGO_DIR='galago-3.8alpha'
URL="http://ciir.cs.umass.edu/~jfoley/${GALAGO_DIR}.tar.gz"
TMPDIR="tmp/"

if [[ ! -f ${GALAGO_DIR}.tar.gz ]]; then
  wget ${URL} -O ${GALAGO_DIR}.tar.gz
fi

if [[ ! -f ${GALAGO_DIR}/bin/galago ]]; then
  rm -rf ${GALAGO_DIR}
  tar -xf ${GALAGO_DIR}.tar.gz
fi

GALAGO="${GALAGO_DIR}/bin/galago"


mkdir -p ${TMPDIR}
export JAVA_OPTS="-Djava.io.tmpdir=${TMPDIR} -Xmx7g"
chmod +x ${GALAGO}

# build index if not already:
INDEX_PATH=gov2.galago
LOG_FILE=build_index.log

if [[ ! -f ${INDEX_PATH}/buildManifest.json ]]; then
  ${GALAGO} build --server=true --mode=fork --distrib=16 --filetype=trecweb --nonStemmedPostings=false --stemmedPostings=false --stemmedCounts=true --corpus=false --inputPath=${GOV2_LOCATION} --indexPath=${INDEX_PATH} 1> >(tee ${LOG_FILE}.stdout) 2> >(tee ${LOG_FILE}.stderr)
fi

rm -rf ${TMPDIR} # remove any lingering temporary files

for queries in "701-750" "751-800" "801-850"
do
  query_file=$TOPICS_QRELS/topics.${queries}.txt
  qrel_file=$TOPICS_QRELS/qrels.${queries}.txt
  query_json=q${queries}.json
  python2 make_query_json.py combine $query_file > $query_json # generate title queries
  run_file=galago${queries}.trecrun
  
  if [[ ! -f ${run_file} ]]; then
    #${GALAGO} batch-search ${query_json} --requested=1000 --index=${INDEX_PATH} > ${run_file}
    ${GALAGO} timed-batch-search ${query_json} --repeats=1 --requested=1000 --index=${INDEX_PATH} --outputFile=${run_file} --timesFile=${run_file}.times
  fi
  $TREC_EVAL ${qrel_file} ${run_file} > galago${queries}.treceval
done

