source ../common.sh
echo "Compiling ingester project..."
cd ingester
mvn clean compile assembly:single
cd ..

echo "Starting indexing..."
rm -rf gov2.lucene
java -cp lib/lucene-core-5.2.1.jar:lib/lucene-backward-codecs-5.2.1.jar:lib/lucene-analyzers-common-5.2.1.jar:lib/lucene-benchmark-5.2.1.jar:lib/lucene-queryparser-5.2.1.jar:.:ingester/target/ingester-0.0.1-SNAPSHOT-jar-with-dependencies.jar luceneingester.TrecIngester -dataDir $GOV2_LOCATION -indexPath gov2.lucene -threadCount 32 -docCountLimit -1 

echo "Evaluating..."
java -cp lib/lucene-core-5.2.1.jar:lib/lucene-backward-codecs-5.2.1.jar:lib/lucene-analyzers-common-5.2.1.jar:lib/lucene-benchmark-5.2.1.jar:lib/lucene-queryparser-5.2.1.jar:.:ingester/target/ingester-0.0.1-SNAPSHOT-jar-with-dependencies.jar luceneingester.TrecQueryDriver ../../topics-and-qrels/topics.701-750.txt ../../topics-and-qrels/qrels.701-750.txt submission_701.txt gov2.lucene/index T > submission_701.log
java -cp lib/lucene-core-5.2.1.jar:lib/lucene-backward-codecs-5.2.1.jar:lib/lucene-analyzers-common-5.2.1.jar:lib/lucene-benchmark-5.2.1.jar:lib/lucene-queryparser-5.2.1.jar:.:ingester/target/ingester-0.0.1-SNAPSHOT-jar-with-dependencies.jar luceneingester.TrecQueryDriver ../../topics-and-qrels/topics.751-800.txt ../../topics-and-qrels/qrels.751-800.txt submission_751.txt gov2.lucene/index T > submission_751.log
java -cp lib/lucene-core-5.2.1.jar:lib/lucene-backward-codecs-5.2.1.jar:lib/lucene-analyzers-common-5.2.1.jar:lib/lucene-benchmark-5.2.1.jar:lib/lucene-queryparser-5.2.1.jar:.:ingester/target/ingester-0.0.1-SNAPSHOT-jar-with-dependencies.jar luceneingester.TrecQueryDriver  ../../topics-and-qrels/topics.801-850.txt ../../topics-and-qrels/qrels.801-850.txt submission_801.txt gov2.lucene/index T > submission_801.log

echo "Results:"
echo "-------"
../../eval/trec_eval.9.0/trec_eval ../../topics-and-qrels/qrels.701-750.txt submission_701.txt
echo "-------"
../../eval/trec_eval.9.0/trec_eval ../../topics-and-qrels/qrels.751-800.txt submission_751.txt
echo "-------"
../../eval/trec_eval.9.0/trec_eval ../../topics-and-qrels/qrels.801-850.txt submission_801.txt

