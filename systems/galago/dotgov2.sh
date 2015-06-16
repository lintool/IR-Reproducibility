#!/bin/bash
set -efu

source ../common.sh

GALAGO='galago-3.8alpha'
URL="http://ciir.cs.umass.edu/~jfoley/${GALAGO}.tar.gz"
TMPDIR="/media/workspace/tmp/"

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
for x in $(seq 0 15); do
  INPUT_FILE=$(printf "../ids/gov2.ids%02d.list" $x)
  OUTPUT_FILE=$(printf "gov2.%02d.galago" $x)
  LOG_FILE=$(printf "build_index.%02d.log" $x)

  if [[ ! -f ${OUTPUT_FILE}/buildManifest.json ]]; then
    echo "${INPUT_FILE}..${OUTPUT_FILE}..${LOG_FILE}"
    bin/galago build --filetype=trecweb --nonStemmedPostings=false --corpus=false --inputPath=${INPUT_FILE} --indexPath=${OUTPUT_FILE} 2>&1 > ${LOG_FILE} &
  fi
done


for queries in "701-750" "751-800" "801-850"
do
  query_file=../$TOPICS_QRELS/topics.${queries}.txt
  qrel_file=../$TOPICS_QRELS/qrels.${queries}.txt
  query_json=q${queries}.json
  python2 ../make_query_json.py $query_file > $query_json # generate title queries
  run_file=galago${queries}.trecrun
  
  if [[ ! -f ${run_file} ]]; then
    bin/galago batch-search ${query_json} --requested=1000 ../index.json > ${run_file}
  fi
  ../$TREC_EVAL ${qrel_file} ${run_file} > galago${queries}.treceval
done
