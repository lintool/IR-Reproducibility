source ../common.sh

JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_71.jdk/Contents/Home

CLEF_LOCATION=/Users/dibuccio/Projects/research/activities/collections/CLEF/corpora

rm -r clef/target

if [[ ! -f clef/target/lucene-clef-1.0-jar-with-dependencies.jar ]]; then
	echo "Compiling lucene-clef project..."
	cd clef
	mvn clean compile assembly:single
	cd ..
fi

cd ../../

ROOT_PATH=$(pwd);

mkdir -p $ROOT_PATH/runs

SYSTEM_PATH=$ROOT_PATH/systems/lucene;

cd $SYSTEM_PATH

while read line;do
	# load indexing and retrieval options from the clef_runs file
	lang=$(echo "$line" | cut -d$'\t' -f1);
	use_stemmer=$(echo "$line" | cut -d$'\t' -f2);
	use_stoplist=$(echo "$line" | cut -d$'\t' -f3);
	model=$(echo "$line" | cut -d$'\t' -f4);
	
	sh $SYSTEM_PATH/clef_experiments.sh -l $lang -cp $CLEF_LOCATION -stm $use_stemmer -sl $use_stoplist -r $model

done < $SYSTEM_PATH/clef_runs

