#!/bin/bash
set -ef

pushd ..
source ../common.sh
popd

INDEX=$1
RANKER=$2

OPTIONS=""

if [ "$RANKER" == "DPH" ];
then
 	OPTIONS="$OPTIONS -Dtrec.model=DPH"
elif [ "$RANKER" == "DPH_QE" ];
then
  OPTIONS="$OPTIONS -Dtrec.model=DPH"
  OPTIONS="$OPTIONS -Dquerying.default.controls=qe:on"
  if [ ! -e "var/index/data.direct.bf" ];
  then
    TERRIER_HEAP_MEM=100g bin/trec_terrier.sh -id
    du -csh var/index/
  fi
elif [[ "$RANKER" == "BM25" ]]; then
	OPTIONS="$OPTIONS -Dtrec.model=BM25"
elif [[ "$RANKER" == "DPH_Prox" ]]; then
  OPTIONS="$OPTIONS -Dtrec.model=DPH"
	OPTIONS="$OPTIONS -Dmatching.dsms=DFRDependenceScoreModifier"
	OPTIONS="$OPTIONS -Dproximity.dependency.type=SD"
	OPTIONS="$OPTIONS -Dproximity.ngram.length=5"
#elif [[ "$RANKER" == "LTR" ]]; then
#  pwd
#  exec ../dotgov2-ltr-ranker.sh $INDEX $RANKER
fi

for queries in "701-750" "751-800" "801-850"
do
	query_file=../$TOPICS_QRELS/topics.${queries}.txt
	qrel_file=../$TOPICS_QRELS/qrels.${queries}.txt
	stat_file=${INDEX}.${RANKER}.${queries}.search_stats.txt
	run_file=$PWD/${INDEX}.${RANKER}.terrier.${queries}.txt

	TERRIER_HEAP_MEM=26g bin/trec_terrier.sh -r -Dtrec.topics=$query_file -Dtrec.results.file=$run_file $OPTIONS > $stat_file 2>&1
	../$TREC_EVAL ${qrel_file} ${run_file}| tee -a $stat_file

	#grep 'Total Time to Search' ${stat_file} | sed \$d
done
