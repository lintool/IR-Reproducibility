source ../common.sh
echo "Compiling ingester project..."
cd ingester
mvn clean compile assembly:single
cd ..

echo "Starting indexing..."
rm -rf gov2.lucene
java -cp lib/lucene-core-5.2.1.jar:lib/lucene-backward-codecs-5.2.1.jar:lib/lucene-analyzers-common-5.2.1.jar:lib/lucene-benchmark-5.2.1.jar:lib/lucene-queryparser-5.2.1.jar:.:ingester/target/ingester-0.0.1-SNAPSHOT-jar-with-dependencies.jar luceneingester.Gov2IngesterLucene $GOV2_LOCATION gov2.lucene

echo "Evaluating..."
java -cp lib/lucene-core-5.2.1.jar:lib/lucene-backward-codecs-5.2.1.jar:lib/lucene-analyzers-common-5.2.1.jar:lib/lucene-benchmark-5.2.1.jar:lib/lucene-queryparser-5.2.1.jar:. org.apache.lucene.benchmark.quality.trec.QueryDriver ../../topics-and-qrels/topics.701-750.txt ../../topics-and-qrels/qrels.701-750.txt submission_701.txt gov2.lucene TDN > submission_701.log
java -cp lib/lucene-core-5.2.1.jar:lib/lucene-backward-codecs-5.2.1.jar:lib/lucene-analyzers-common-5.2.1.jar:lib/lucene-benchmark-5.2.1.jar:lib/lucene-queryparser-5.2.1.jar:. org.apache.lucene.benchmark.quality.trec.QueryDriver ../../topics-and-qrels/topics.751-800.txt ../../topics-and-qrels/qrels.751-800.txt submission_751.txt gov2.lucene TDN > submission_751.log
java -cp lib/lucene-core-5.2.1.jar:lib/lucene-backward-codecs-5.2.1.jar:lib/lucene-analyzers-common-5.2.1.jar:lib/lucene-benchmark-5.2.1.jar:lib/lucene-queryparser-5.2.1.jar:. org.apache.lucene.benchmark.quality.trec.QueryDriver ../../topics-and-qrels/topics.801-850.txt ../../topics-and-qrels/qrels.801-850.txt submission_801.txt gov2.lucene TDN > submission_801.log

echo "\nResults:"
../../eval/trec_eval.9.0/trec_eval ../../topics-and-qrels/qrels.701-750.txt submission_701.txt 
../../eval/trec_eval.9.0/trec_eval ../../topics-and-qrels/qrels.751-800.txt submission_751.txt 
../../eval/trec_eval.9.0/trec_eval ../../topics-and-qrels/qrels.801-850.txt submission_801.txt

