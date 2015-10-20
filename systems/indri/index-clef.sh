#!/bin/sh

#usage: ./index.sh language
#language can be bg,de,es,fa,fi,fr,hu,it,nl,pt,ru,sv

#set lemur bin directory
lemurdir=/u/xiaojiex/ir/lemur/bin

#set indexing parameter file directory
indexParaDir=/u/xiaojiex/ir/excute/clefmono

date
echo "building index started" 
$lemurdir/IndriBuildIndex $indexParaDir/indexParaSP_$1
echo "building index finished"
date
