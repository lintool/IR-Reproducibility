#!/bin/bash
set -e

#sudo apt-add-repository -y ppa:webupd8team/java
#sudo apt-get -y update
#sudo apt-get -y install oracle-java8-installer
#sudo apt-get -y install ruby

version=5.4

source ../common.sh

WORK_DIR=.

if [[ ! -f mg4j-big-$version-bin.tar.gz ||  ! -f mg4j-big-deps.tar.gz ]]; then
	curl http://mg4j.di.unimi.it/mg4j-big-$version-bin.tar.gz >mg4j-big-$version-bin.tar.gz
	curl http://mg4j.di.unimi.it/mg4j-big-deps.tar.gz >mg4j-big-deps.tar.gz
fi

tar -zxvf mg4j-big-$version-bin.tar.gz
tar -zxvf mg4j-big-deps.tar.gz

export CLASSPATH=$(find -iname \*.jar | paste -d: -s)

starttime=$(date +%s)

if false; then

# Sequential

java -Xmx8G -server \
	it.unimi.di.big.mg4j.document.TRECDocumentCollection \
		-f HtmlDocumentFactory -p encoding=iso-8859-1 -z $WORK_DIR/gov2.collection $(find $GOV2_LOCATION -type f)

java -Xmx8G -server \
	it.unimi.di.big.mg4j.tool.IndexBuilder -s 2000000 -S $WORK_DIR/gov2.collection -t EnglishStemmer -I text $WORK_DIR/gov2

else

# Parallel

rm -f $WORK_DIR/gov2-split-*-text@*.* $WORK_DIR/gov2-split-*.titles split-*

TMP=$(mktemp)
find $GOV2_LOCATION -type f | sort >$TMP
split -n l/16 $TMP split-

(for split in split-*; do
(

	java -Xmx8G -server \
		it.unimi.di.big.mg4j.document.TRECDocumentCollection \
			-f HtmlDocumentFactory -p encoding=iso-8859-1 -z $WORK_DIR/gov2-$split.collection $(cat $split)

	java -Xmx8G -server \
		it.unimi.di.big.mg4j.tool.Scan -s 1000000 -S $WORK_DIR/gov2-$split.collection -t EnglishStemmer -I text $WORK_DIR/gov2-$split

)& 

done

wait)

java -server it.unimi.di.big.mg4j.tool.Concatenate $WORK_DIR/gov2-text \
	$(find $WORK_DIR -iname gov2-split-\*-text@\*.sizes | sort | sed s/.sizes//)
cat $(find $WORK_DIR -iname gov2-split-\*.titles | sort) >$WORK_DIR/gov2.titles

java -server it.unimi.dsi.sux4j.mph.MWHCFunction -s 32 $WORK_DIR/gov2-text.mwhc $WORK_DIR/gov2-text.terms

java -server it.unimi.dsi.sux4j.util.SignedFunctionStringMap $WORK_DIR/gov2-text.mwhc $WORK_DIR/gov2-text.termmap

fi

endtime=$(date +%s)

echo "Indexing time: $((endtime-starttime))s"
