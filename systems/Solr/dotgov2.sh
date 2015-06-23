source ../common.sh
echo "Compiling ingester project..."
cd solrbenchmarks
mvn clean compile assembly:single
cd ..

echo "Downloading Solr 5.2.1..."
wget http://ftp.wayne.edu/apache/lucene/solr/5.2.1/solr-5.2.1.tgz
tar -xvf solr-5.2.1.tgz
cd solr-5.2.1

echo "Starting Solr..."
bin/solr -c
bin/solr -c -z localhost:9983 -p 8984
bin/solr -c -z localhost:9983 -p 8985
bin/solr -c -z localhost:9983 -p 8986
bin/solr -c -z localhost:9983 -p 8987
bin/solr -c -z localhost:9983 -p 8988
bin/solr -c -z localhost:9983 -p 8989
bin/solr -c -z localhost:9983 -p 8990


server/scripts/cloud-scripts/zkcli.sh -cmd upconfig -zkhost localhost:9983 -confname dotgov2 -solrhome server/solr -confdir ../conf

bin/solr create -c dotgov2 -n dotgov2 -shards 16

cd ..
echo "Starting indexing..."
java -cp .:solrbenchmarks/target/solrbenchmarks-0.0.1-SNAPSHOT-jar-with-dependencies.jar solrbenchmarks.Gov2Ingester $GOV2_LOCATION http://localhost:8983/solr/dotgov2

echo "Stopping Solr..."
cd solr-5.2.1
bin/solr stop -all
cd ..
rm -rf solr-5.2.1
