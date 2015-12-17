source ../common.sh
echo "Compiling ingester project..."
cd ingester
mvn clean compile assembly:single
cd ..

maxmemory="-Xmx15G"

echo "Starting indexing..."
#rm -rf gov2.lucene

# Counts index
java $maxmemory -cp lib/lucene-core-5.2.1.jar:lib/lucene-backward-codecs-5.2.1.jar:lib/lucene-analyzers-common-5.2.1.jar:lib/lucene-benchmark-5.2.1.jar:lib/lucene-queryparser-5.2.1.jar:.:ingester/target/ingester-0.0.1-SNAPSHOT-jar-with-dependencies.jar luceneingester.TrecIngester -dataDir $GOV2_LOCATION -indexPath gov2.lucene.cnt -threadCount 32 -docCountLimit -1

#Force merge
echo "Force merging..."
java $maxmemory -cp lib/lucene-core-5.2.1.jar:lib/lucene-backward-codecs-5.2.1.jar:lib/lucene-analyzers-common-5.2.1.jar:lib/lucene-benchmark-5.2.1.jar:lib/lucene-queryparser-5.2.1.jar:.:ingester/target/ingester-0.0.1-SNAPSHOT-jar-with-dependencies.jar luceneingester.ForceMerge gov2.lucene.cnt/index

# Positional index
java $maxmemory -cp lib/lucene-core-5.2.1.jar:lib/lucene-backward-codecs-5.2.1.jar:lib/lucene-analyzers-common-5.2.1.jar:lib/lucene-benchmark-5.2.1.jar:lib/lucene-queryparser-5.2.1.jar:.:ingester/target/ingester-0.0.1-SNAPSHOT-jar-with-dependencies.jar luceneingester.TrecIngester -dataDir $GOV2_LOCATION -indexPath gov2.lucene.pos -positions -threadCount 32 -docCountLimit -1

echo "Force merging..."
java $maxmemory -cp lib/lucene-core-5.2.1.jar:lib/lucene-backward-codecs-5.2.1.jar:lib/lucene-analyzers-common-5.2.1.jar:lib/lucene-benchmark-5.2.1.jar:lib/lucene-queryparser-5.2.1.jar:.:ingester/target/ingester-0.0.1-SNAPSHOT-jar-with-dependencies.jar luceneingester.ForceMerge gov2.lucene.pos/index


for index in "cnt" "pos"
do
	echo "Evaluation index ${index}"
	for queries in "701-750" "751-800" "801-850"
	do
		query_file=$TOPICS_QRELS/topics.${queries}.txt
		qrel_file=$TOPICS_QRELS/qrels.${queries}.txt
		run_file=submission_${queries}_${index}.txt
		stat_file=submission_${queries}_${index}.log
		eval_file=submission_${queries}_${index}.eval

		java $maxmemory -cp lib/lucene-core-5.2.1.jar:lib/lucene-backward-codecs-5.2.1.jar:lib/lucene-analyzers-common-5.2.1.jar:lib/lucene-benchmark-5.2.1.jar:lib/lucene-queryparser-5.2.1.jar:.:ingester/target/ingester-0.0.1-SNAPSHOT-jar-with-dependencies.jar luceneingester.TrecDriver ${query_file} ${qrel_file} ${run_file} gov2.lucene.${index}/index T > ${stat_file}

		${TREC_EVAL} ${qrel_file} ${run_file} > ${eval_file}
	done
done
