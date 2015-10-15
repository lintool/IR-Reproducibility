#! /bin/sh

source ../common.sh

# This script allows experiments based on Apache Lucene and CLEF collections to be replicated.

## declare the langs array
declare -a langs=("bg" "de" "es" "fa" "fi" "fr" "hu" "it" "nl" "pt" "ru" "sv");

## declare the rank models array
declare -a models=("BM25");

topicFields="title;description";

if [ "$1" == "-h" ]; then
  printf "Usage: `basename $0` \n\n" >&2
  printf "Input parameters: \n" >&2
  printf "'-l': the language expressed as ISO 639-1 (two-letter codes); e.g. nl for Dutch or it for Italian.\n" >&2
  echo "Valid languages for CLEF experiments are: ${langs[@]}";
  printf "'-cp': the path where the document collections are stored. \n" >&2
  printf "'-stm': the stemmer specification; y for 'yes' or n for 'no'. \n" >&2
  printf "'-sl': the stopword list specification; y for 'yes' or n for 'no'. \n" >&2
  printf "'-r': the ranking model specification; e.g. BM25 for bm25. \n" >&2
  echo "Allowed models for CLEF experiments and Apache Lucene 5.2.1 are: ${models[@]}";
  printf "'-v': verbose mode. \n" >&2
  exit 0
else
	# check the input paramenters
	if [ $# -lt 10 ]; then
		echo "You must specify all the input parameters: -l, -cp, -stm, -sl, -r" 1>&2
		exit 1
	else
		echo "Starting the execution.";
		if [ "$1" == "-l" ]; then
			lang=$2;
			tmp=false;
			for i in "${langs[@]}"
			do
			    if [ "$i" == "$lang" ] ; then
			        tmp=true;
			        break;
			    fi
			done

			if  [ "$tmp" = false ]; then
				printf "first parameter must be the language -l expressed as ISO 639-1 (two-letter codes)\n";
  				echo "Valid languages for CLEF experiments are: ${langs[@]}";
  				exit 1
  			fi
  				 
		else
			echo "The first parameter must be the language -l expressed as ISO 639-1 (two-letter codes)"
			exit 1
		fi

		if [ "$3" == "-cp" ]; then
			collection_path=$4;
		else
			echo "The second parameter must be the collection path -cp"
			exit 1
		fi

		if [ "$5" == "-stm" ]; then
			if [ "$6" == "y" ]; then
				stm=true;
			elif [ "$6" == "n" ]; then
				stm=false;
			else
				printf "The value %s is not valid for -stm \n" "$6" >&2
				printf "For the -stm parameter you must specify y for yes or n for no \n" >&2
				exit 1
			fi
		else
			echo "The third parameter must be stemmer specification -stm (y = yes; n = no)"
			exit 1
		fi	

		if [ "$7" == "-sl" ]; then
			if [ "$8" == "y" ]; then
				sl=true;
			elif [ "$8" == "n" ]; then
				sl=false;
			else
				printf "The value %s is not valid for -sl \n" "$6" >&2
				printf "For the -sl parameter you must specify y for yes or n for no \n" >&2
				exit 1
			fi
		else
			echo "The fourth parameter must be stopword list specification -sl (y = yes; n = no)"
			exit 1
		fi	

		if [ "$9" == "-r" ]; then
			rank_model=${10};

			tmp=false;
			for i in "${models[@]}"
			do
			    if [ "$i" == "$rank_model" ] ; then
			        tmp=true;
			        break;
			    fi
			done

			if  [ "$tmp" = false ]; then
				printf "The last parameter must be the ranking model.\n";
  				echo "Allowed models for CLEF experiments and Apache Lucene 5.2.1 are: ${models[@]}";
  				exit 1
  			fi
		else
			echo "The fourth parameter must be stopword list specification -sl (y = yes; n = no)"
			exit 1
		fi	

		if [ "${11}" == "-v" ]; then
			verbose=true;
		else
			verbose=false;
		fi
		
	fi
fi

LUCENE_PATH=$(pwd);
cd ../../
ROOT_PATH=$(pwd);
cd $LUCENE_PATH

## path to the topics file
topics=$ROOT_PATH/topics-and-qrels/CLEF/topics/"$lang"_topics.xml;

## path to the qrels file
qrels=$ROOT_PATH/topics-and-qrels/CLEF/qrels/"$lang"_qrels.txt;

## create required folders

mkdir -p $ROOT_PATH/results/CLEF/lucene/"$lang";

mkdir -p $ROOT_PATH/runs/CLEF/lucene/"$lang";

indexDir=$lang;

if [ "$sl" = true ]; then
	stopsetType="CUSTOM";
	stoplist=$ROOT_PATH/resources/CLEF/"$lang"_sl.txt;
	stoplistOpt="-Dstopset.type=$stopsetType -Dstopset.path=$stoplist";
	indexDir="$indexDir"_Stopword;
else
	stoplistOpt="-Dstopset.type=\"EMPTY\"";
fi

if [ "$stm" = true ]; then
	indexDir="$indexDir"_Stemmer;
	stemmer="DEFAULT";
else
	stemmer="NONE";
fi

runTag="$indexDir"_"$rank_model";

runFile=$ROOT_PATH/runs/CLEF/lucene/"$lang"/"$runTag".txt;

indexDir="${LUCENE_PATH}/indexes/$indexDir"; 

OPTIONS="-Dindex.path=$indexDir -Dcorpora.path=$collection_path -Dstemmer=$stemmer -Dlanguage=$lang $stoplistOpt";


## do the index, if it does not exist
if [ -d "$indexDir" ]; then
	if  [ "$verbose" = true ]; then
		printf "The index already exists in %s \n" "$indexDir" >&2
	fi	
else
	java -jar $OPTIONS clef/target/lucene-clef-1.0-jar-with-dependencies.jar -i
fi


if  [ "$verbose" = true ]; then
	printf "Performing the retrieval with the ranking model %s \n" "$rank_model" >&2
fi


## do the retrieval

OPTIONS="$OPTIONS -Drun.model=$rank_model -Drun.path=$runFile -Drun.tag=$runTag -Dtopics.path=$topics -Dtopics.fields=$topicFields";

java -jar $OPTIONS clef/target/lucene-clef-1.0-jar-with-dependencies.jar -r

${TREC_EVAL} -q -c -M1000 $qrels $runFile>${ROOT_PATH}/results/CLEF/lucene/"$lang"/"$runTag".txt

