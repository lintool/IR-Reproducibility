#!/bin/bash
set -e

#sudo apt-add-repository -y ppa:webupd8team/java
#sudo apt-get -y update
#sudo apt-get -y install oracle-java8-installer
#sudo apt-get -y install ruby

version=5.4

source ../common.sh

#export GOV2_LOCATION=/mnt/extra/text/GOV2/GX000/

if [[ ! -f mg4j-big-$version-bin.tar.gz ||  ! -f mg4j-big-deps.tar.gz ]]; then
	curl http://mg4j.di.unimi.it/mg4j-big-$version-bin.tar.gz >mg4j-big-$version-bin.tar.gz
	curl http://mg4j.di.unimi.it/mg4j-big-deps.tar.gz >mg4j-big-deps.tar.gz
fi

tar -zxvf mg4j-big-$version-bin.tar.gz
tar -zxvf mg4j-big-deps.tar.gz

export CLASSPATH=$(find -iname \*.jar | paste -d: -s)

if false; then

java -Xmx30G -server \
	it.unimi.di.big.mg4j.document.TRECDocumentCollection \
		-f HtmlDocumentFactory -p encoding=iso-8859-1 -z /media/workspace/gov2.collection $(find $GOV2_LOCATION -type f)

java -Xmx30G -server \
	it.unimi.di.big.mg4j.tool.IndexBuilder -s 2000000 -S /media/workspace/gov2.collection -t EnglishStemmer -I text -c POSITIONS:NONE /media/workspace/gov2

else

rm -f /media/workspace/gov2-split-*-text@*.* /media/workspace/gov2-split-*.titles split-*

TMP=$(mktemp)
find $GOV2_LOCATION -type f | sort >$TMP
split -n l/16 $TMP split-

(for split in split-*; do
(

	java -Xmx4G -server \
		it.unimi.di.big.mg4j.document.TRECDocumentCollection \
			-z -f HtmlDocumentFactory -p encoding=iso-8859-1 /media/workspace/gov2-$split.collection $(cat $split)

	java -Xmx4G -server \
		it.unimi.di.big.mg4j.tool.Scan -s 2000000 -S /media/workspace/gov2-$split.collection -t EnglishStemmer -I text -c COUNTS /media/workspace/gov2-$split

)& 

done

wait)

java -server it.unimi.di.big.mg4j.tool.Concatenate -c POSITIONS:NONE /media/workspace/gov2-text \
	$(find /media/workspace -iname gov2-split-\*-text@\*.sizes | sort | sed s/.sizes//)
cat $(find /media/workspace -iname gov2-split-\*.titles | sort) >/media/workspace/gov2.titles

java -server it.unimi.dsi.sux4j.mph.MWHCFunction -s 32 /media/workspace/gov2-text.mwhc /media/workspace/gov2-text.terms

java -server it.unimi.dsi.sux4j.util.SignedFunctionStringMap /media/workspace/gov2-text.mwhc /media/workspace/gov2-text.termmap

fi
