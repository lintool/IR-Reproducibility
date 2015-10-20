#!/bin/sh

#usage: ./query_LM.sh language
#language can be bg,de,es,fa,fi,fr,hu,it,nl,pt,ru,sv

#set lemur bin directory
lemurdir=/u/xiaojiex/ir/lemur/bin

#set retrieval parameter file directory
queryParaDir=/u/xiaojiex/ir/excute/clefmono

#set retrieval result directory
queryResultDir=$queryParaDir/baseline

date
echo "retrieval started" 
$lemurdir/IndriRunQuery $queryParaDir/queryParaLMSP_$1 > $queryResultDir/result_LMSP_file_$1
echo "retrieval finished"
date