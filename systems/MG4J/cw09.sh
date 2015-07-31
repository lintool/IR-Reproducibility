#!/bin/bash
set -e

#sudo apt-add-repository -y ppa:webupd8team/java
#sudo apt-get -y update
#sudo apt-get -y install oracle-java8-installer
#sudo apt-get -y install ruby

version=5.4.1

source ../common.sh

WORK_DIR=.

#if [[ ! -f mg4j-big-$version-bin.tar.gz ||  ! -f mg4j-big-deps.tar.gz ]]; then
#	curl http://mg4j.di.unimi.it/mg4j-big-$version-bin.tar.gz >mg4j-big-$version-bin.tar.gz
#	curl http://mg4j.di.unimi.it/mg4j-big-deps.tar.gz >mg4j-big-deps.tar.gz
#fi

#tar -zxvf mg4j-big-$version-bin.tar.gz
#tar -zxvf mg4j-big-deps.tar.gz

#export CLASSPATH=$(find -iname \*.jar | paste -d: -s)

starttime=$(date +%s)

# Parallel

rm -f $WORK_DIR/cw09-split-*-text@*.* $WORK_DIR/cw09-split-*.titles split-*

TMP=$(mktemp)
find $CW09B_LOCATION -iname \*.gz -type f | sort >$TMP
split -n l/16 $TMP split-

(for split in split-*; do
(
	splitfifo=fifo-$split
	rm -f $splitfifo
	mkfifo $splitfifo 
	( zcat $(cat $split) | java -server it.unimi.di.law.warc.tool.WarcContentLengthFixer 0.18 >$splitfifo ) &

	java -Xmx8G -server \
		it.unimi.di.big.mg4j.document.WarcDocumentSequence \
			-f it.unimi.di.big.mg4j.document.HtmlDocumentFactory -p encoding=iso-8859-1 $WORK_DIR/cw09-$split.sequence $splitfifo

	java -Xmx8G -server -Dit.unimi.di.law.warc.io.version=false \
		it.unimi.di.big.mg4j.tool.Scan -s 1000000 -S $WORK_DIR/cw09-$split.sequence -t EnglishStemmer -I text -c COUNTS $WORK_DIR/cw09-$split

)& 

done

wait)

java -server it.unimi.di.big.mg4j.tool.Concatenate -c POSITIONS:NONE $WORK_DIR/cw09-text \
	$(find $WORK_DIR -iname cw09-split-\*-text@\*.sizes | sort | sed s/.sizes//)
cat $(find $WORK_DIR -iname cw09-split-\*.titles | sort) >$WORK_DIR/cw09.titles

java -server it.unimi.dsi.sux4j.mph.MWHCFunction -s 32 $WORK_DIR/cw09-text.mwhc $WORK_DIR/cw09-text.terms

java -server it.unimi.dsi.sux4j.util.SignedFunctionStringMap $WORK_DIR/cw09-text.mwhc $WORK_DIR/cw09-text.termmap


endtime=$(date +%s)

echo "Indexing time: $((endtime-starttime))s"
