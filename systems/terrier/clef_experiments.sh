#! /bin/sh

source ../common.sh

if [[ ! -f terrier-4.0.tar.gz ]]; then
	curl http://www.dcs.gla.ac.uk/~craigm/terrier-4.0.tar.gz> terrier-4.0.tar.gz
fi
rm -rf terrier-4.0
tar -zxvf terrier-4.0.tar.gz

# This script allows the repetition of the experiments based on Terrier and CLEF collections

## declare the langs array
declare -a langs=("bg" "de" "es" "fa" "fi" "hu" "it" "nl" "pt" "ru" "sv");

## declare the rank models array
declare -a models=("BM25" "PL2" "TF_IDF" "Hiemstra_LM");

## the corpus sizes
BG_CORPUS_SIZE=69195;
DE_CORPUS_SIZE=225371;
ES_CORPUS_SIZE=454045;
FA_CORPUS_SIZE=166774;
FI_CORPUS_SIZE=55344;
FR_CORPUS_SIZE=177452;
HU_CORPUS_SIZE=49530;
IT_CORPUS_SIZE=157558;
NL_CORPUS_SIZE=190604;
PT_CORPUS_SIZE=210734;
RU_CORPUS_SIZE=16716;
SV_CORPUS_SIZE=142819;



if [ "$1" == "-h" ]; then
  printf "Usage: `basename $0` \n\n" >&2
  printf "Input parameters: \n" >&2
  printf "'-l': the language expressed as ISO 639-1 (two-letter codes); e.g. nl for Dutch or it for Italian.\n" >&2
  echo "Valid languages for CLEF experiments are: ${langs[@]}";
  printf "'-cp': the path where the document collections are stored. \n" >&2
  printf "'-stm': the stemmer specification; y for 'yes' or n for 'no'. \n" >&2
  printf "'-sl': the stopword list specification; y for 'yes' or n for 'no'. \n" >&2
  printf "'-r': the ranking model specification; e.g. BM25 for bm25 or TF_IDF for tfidf. \n" >&2
  echo "Allowed models for CLEF experiments and Terrier 4.0 are: ${models[@]}";
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
				if [ "$lang" = "bg" -o "$lang" = "fa" ]; then
					printf "The value %s is not valid for -stm when the language is %s, because Terrier 4.0 does not provide a stemmer for this language.\n" "$6" "$lang" >&2
					printf "Please set the -stm parameter to n when lang is %s\n" "$lang" >&2
					exit 1
				else
					stm=true;
				fi
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
  				echo "Allowed models for CLEF experiments and Terrier 4.0 are: ${models[@]}";
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

## path to the topics file
topics=../../topics-and-qrels/CLEF/topics/"$lang"_topics.xml;

## path to the qrels file
cd ../..
qrels=$(pwd)/topics-and-qrels/CLEF/qrels/"$lang"_qrels.txt;
cd systems/terrier

mkdir ../../results/CLEF/terrier/"$lang";


## create the tmp dir for the corpus
mkdir corpus;

if  [ "$verbose" = true ]; then
	printf "Creating the %s corpus copying the documents from %s into the directory corpus \n" "$lang" "$collection_path" >&2
fi

case "$lang" in
    bg) indexDir="$lang";

		if [ "$sl" = true ]; then

			stoplist=../../../../resources/"$lang"_sl.txt;
			indexDir="$indexDir"_Stopword;
		else
			stoplist="";
		fi

		if [ "$stm" = true ]; then
			stemmer=GermanSnowballStemmer;
			indexDir="$indexDir"_Stemmer;
		else
			stemmer="";
		fi

		runTag="$indexDir"_"$rank_model";

		mkdir ../../runs/CLEF/terrier/"$lang";

		cd ../..
		runFile=$(pwd)/runs/CLEF/terrier/"$lang"/"$runTag".txt;
		cd systems/terrier
		indexScriptDir=$indexDir;
		indexDir=../../indexes/"$indexDir"; 
		indexTmpDir=./indexes/"$indexScriptDir";

	
		if [ -d "$indexTmpDir" ]; then
				if  [ "$verbose" = true ]; then
					printf "The index already exists in %s and we do not need to copy the corpus \n" "$indexDir" >&2
				fi	
		else
			ls -1 $collection_path/SEGA2002 | xargs -i cp $collection_path/SEGA2002/{} ./corpus/;
			ls -1 $collection_path/STANDART2002 | xargs -i cp $collection_path/STANDART2002/{} ./corpus/;

			## create the collection.spec file needed for indexing purposes
			./terrier-4.0/bin/trec_setup.sh ./corpus

			## count the number of docs
			docs=$(wc -l < ./terrier-4.0/etc/collection.spec);
			##let "docs-=1";
			let docs=$docs-1;
			
			## check if the total number of docs to be indexes is correct
			if [ "$BG_CORPUS_SIZE" != "$docs" ]; then
				printf "The size (%s docs) of the current corpus does not correspond to the corpus size used for defining the baselines; indeed, the %s corpus must count %s documents.\n" "$docs" "$lang" "$BG_CORPUS_SIZE" >&2
				exit 1
			fi

		fi
       ;; 
    de) indexDir="$lang";

		if [ "$sl" = true ]; then

			stoplist=../../../../resources/"$lang"_sl.txt;
			indexDir="$indexDir"_Stopword;
		else
			stoplist="";
		fi

		if [ "$stm" = true ]; then
			stemmer=GermanSnowballStemmer;
			indexDir="$indexDir"_Stemmer;
		else
			stemmer="";
		fi

		runTag="$indexDir"_"$rank_model";

		mkdir ../../runs/CLEF/terrier/"$lang";

		cd ../..
		runFile=$(pwd)/runs/CLEF/terrier/"$lang"/"$runTag".txt;
		cd systems/terrier
		indexScriptDir=$indexDir;
		indexDir=../../indexes/"$indexDir"; 
		indexTmpDir=./indexes/"$indexScriptDir";

	
		if [ -d "$indexTmpDir" ]; then
				if  [ "$verbose" = true ]; then
					printf "The index already exists in %s and we do not need to copy the corpus \n" "$indexDir" >&2
				fi	
		else
			ls -1 $collection_path/FRANKFURTER1994 | xargs -i cp $collection_path/FRANKFURTER1994/{} ./corpus/;
			ls -1 $collection_path/SDA1994 | xargs -i cp $collection_path/SDA1994/{} ./corpus/;
			ls -1 $collection_path/SPIEGEL1994 | xargs -i cp $collection_path/SPIEGEL1994/{} ./corpus/;
			ls -1 $collection_path/SPIEGEL1995 | xargs -i cp $collection_path/SPIEGEL1995/{} ./corpus/;

			## create the collection.spec file needed for indexing purposes
			./terrier-4.0/bin/trec_setup.sh ./corpus

			## count the number of docs
			docs=$(wc -l < ./terrier-4.0/etc/collection.spec);
			##let "docs-=1";
			let docs=$docs-1;
			
			## check if the total number of docs to be indexes is correct
			if [ "$DE_CORPUS_SIZE" != "$docs" ]; then
				printf "The size (%s docs) of the current corpus does not correspond to the corpus size used for defining the baselines; indeed, the %s corpus must count %s documents.\n" "$docs" "$lang" "$DE_CORPUS_SIZE" >&2
				exit 1
			fi

		fi
       ;; 
    es) indexDir="$lang";

		if [ "$sl" = true ]; then

			stoplist=../../../../resources/"$lang"_sl.txt;
			indexDir="$indexDir"_Stopword;
		else
			stoplist="";
		fi

		if [ "$stm" = true ]; then
			stemmer=SpanishSnowballStemmer;
			indexDir="$indexDir"_Stemmer;
		else
			stemmer="";
		fi

		runTag="$indexDir"_"$rank_model";

		mkdir ../../runs/CLEF/terrier/"$lang";

		cd ../..
		runFile=$(pwd)/runs/CLEF/terrier/"$lang"/"$runTag".txt;
		cd systems/terrier
		indexScriptDir=$indexDir;
		indexDir=../../indexes/"$indexDir"; 
		indexTmpDir=./indexes/"$indexScriptDir";

	
		if [ -d "$indexTmpDir" ]; then
				if  [ "$verbose" = true ]; then
					printf "The index already exists in %s and we do not need to copy the corpus \n" "$indexDir" >&2
				fi	
		else
			cp -r $collection_path/EFE1994 ./corpus/
			cp -r $collection_path/EFE1995 ./corpus/

			## create the collection.spec file needed for indexing purposes
			./terrier-4.0/bin/trec_setup.sh ./corpus

			## count the number of docs
			docs=$(wc -l < ./terrier-4.0/etc/collection.spec);
			##let "docs-=1";
			let docs=$docs-1;
			
			## check if the total number of docs to be indexes is correct
			if [ "$ES_CORPUS_SIZE" != "$docs" ]; then
				printf "The size (%s docs) of the current corpus does not correspond to the corpus size used for defining the baselines; indeed, the %s corpus must count %s documents.\n" "$docs" "$lang" "$ES_CORPUS_SIZE" >&2
				exit 1
			fi

		fi
       ;;    
    fa) indexDir="$lang";

		if [ "$sl" = true ]; then

			stoplist=../../../../resources/"$lang"_sl.txt;
			indexDir="$indexDir"_Stopword;
		else
			stoplist="";
		fi

		if [ "$stm" = true ]; then
			stemmer=TurkishSnowballStemmer;
			indexDir="$indexDir"_Stemmer;
		else
			stemmer="";
		fi

		runTag="$indexDir"_"$rank_model";

		mkdir ../../runs/CLEF/terrier/"$lang";

		cd ../..
		runFile=$(pwd)/runs/CLEF/terrier/"$lang"/"$runTag".txt;
		cd systems/terrier
		indexScriptDir=$indexDir;
		indexDir=../../indexes/"$indexDir"; 
		indexTmpDir=./indexes/"$indexScriptDir";

	
		if [ -d "$indexTmpDir" ]; then
				if  [ "$verbose" = true ]; then
					printf "The index already exists in %s and we do not need to copy the corpus \n" "$indexDir" >&2
				fi	
		else
			ls -1 $collection_path/HAMSHAHRI | xargs -i cp $collection_path/HAMSHAHRI/{} ./corpus/;

			## create the collection.spec file needed for indexing purposes
			./terrier-4.0/bin/trec_setup.sh ./corpus

			## count the number of docs
			docs=$(wc -l < ./terrier-4.0/etc/collection.spec);
			##let "docs-=1";
			let docs=$docs-1;
			
			## check if the total number of docs to be indexes is correct
			if [ "$FA_CORPUS_SIZE" != "$docs" ]; then
				printf "The size (%s docs) of the current corpus does not correspond to the corpus size used for defining the baselines; indeed, the %s corpus must count %s documents.\n" "$docs" "$lang" "$FA_CORPUS_SIZE" >&2
				exit 1
			fi

		fi
       ;;    
    fi) indexDir="$lang";

		if [ "$sl" = true ]; then

			stoplist=../../../../resources/"$lang"_sl.txt;
			indexDir="$indexDir"_Stopword;
		else
			stoplist="";
		fi

		if [ "$stm" = true ]; then
			stemmer=FinnishSnowballStemmer;
			indexDir="$indexDir"_Stemmer;
		else
			stemmer="";
		fi

		runTag="$indexDir"_"$rank_model";

		mkdir ../../runs/CLEF/terrier/"$lang";

		cd ../..
		runFile=$(pwd)/runs/CLEF/terrier/"$lang"/"$runTag".txt;
		cd systems/terrier
		indexScriptDir=$indexDir;
		indexDir=../../indexes/"$indexDir"; 
		indexTmpDir=./indexes/"$indexScriptDir";

	
		if [ -d "$indexTmpDir" ]; then
				if  [ "$verbose" = true ]; then
					printf "The index already exists in %s and we do not need to copy the corpus \n" "$indexDir" >&2
				fi	
		else
			ls -1 $collection_path/AAMULEHTI1994 | xargs -i cp $collection_path/AAMULEHTI1994/{} ./corpus/;
			ls -1 $collection_path/AAMULEHTI1995 | xargs -i cp $collection_path/AAMULEHTI1995/{} ./corpus/;

			## create the collection.spec file needed for indexing purposes
			./terrier-4.0/bin/trec_setup.sh ./corpus

			## count the number of docs
			docs=$(wc -l < ./terrier-4.0/etc/collection.spec);
			##let "docs-=1";
			let docs=$docs-1;
			
			## check if the total number of docs to be indexes is correct
			if [ "$FI_CORPUS_SIZE" != "$docs" ]; then
				printf "The size (%s docs) of the current corpus does not correspond to the corpus size used for defining the baselines; indeed, the %s corpus must count %s documents.\n" "$docs" "$lang" "$FI_CORPUS_SIZE" >&2
				exit 1
			fi

		fi
       ;;  
    fr) indexDir="$lang";

		if [ "$sl" = true ]; then

			stoplist=../../../../resources/"$lang"_sl.txt;
			indexDir="$indexDir"_Stopword;
		else
			stoplist="";
		fi

		if [ "$stm" = true ]; then
			stemmer=FrenchSnowballStemmer;
			indexDir="$indexDir"_Stemmer;
		else
			stemmer="";
		fi

		runTag="$indexDir"_"$rank_model";

		mkdir ../../runs/CLEF/terrier/"$lang";

		cd ../..
		runFile=$(pwd)/runs/CLEF/terrier/"$lang"/"$runTag".txt;
		cd systems/terrier
		indexScriptDir=$indexDir;
		indexDir=../../indexes/"$indexDir"; 
		indexTmpDir=./indexes/"$indexScriptDir";

	
		if [ -d "$indexTmpDir" ]; then
				if  [ "$verbose" = true ]; then
					printf "The index already exists in %s and we do not need to copy the corpus \n" "$indexDir" >&2
				fi	
		else
			ls -1 $collection_path/LEMONDE1994 | xargs -i cp $collection_path/LEMONDE1994/{} ./corpus/;
			ls -1 $collection_path/LEMONDE1995 | xargs -i cp $collection_path/LEMONDE1995/{} ./corpus/;
			ls -1 $collection_path/ATS1994 | xargs -i cp $collection_path/ATS1994/{} ./corpus/;
			ls -1 $collection_path/ATS1995 | xargs -i cp $collection_path/ATS1995/{} ./corpus/;

			## create the collection.spec file needed for indexing purposes
			./terrier-4.0/bin/trec_setup.sh ./corpus

			## count the number of docs
			docs=$(wc -l < ./terrier-4.0/etc/collection.spec);
			##let "docs-=1";
			let docs=$docs-1;
			
			## check if the total number of docs to be indexes is correct
			if [ "$FR_CORPUS_SIZE" != "$docs" ]; then
				printf "The size (%s docs) of the current corpus does not correspond to the corpus size used for defining the baselines; indeed, the %s corpus must count %s documents.\n" "$docs" "$lang" "$FR_CORPUS_SIZE" >&2
				exit 1
			fi

		fi
       ;;    
    hu) indexDir="$lang";

		if [ "$sl" = true ]; then

			stoplist=../../../../resources/"$lang"_sl.txt;
			indexDir="$indexDir"_Stopword;
		else
			stoplist="";
		fi

		if [ "$stm" = true ]; then
			stemmer=HungarianSnowballStemmer;
			indexDir="$indexDir"_Stemmer;
		else
			stemmer="";
		fi

		runTag="$indexDir"_"$rank_model";

		mkdir ../../runs/CLEF/terrier/"$lang";

		cd ../..
		runFile=$(pwd)/runs/CLEF/terrier/"$lang"/"$runTag".txt;
		cd systems/terrier
		indexScriptDir=$indexDir;
		indexDir=../../indexes/"$indexDir"; 
		indexTmpDir=./indexes/"$indexScriptDir";

	
		if [ -d "$indexTmpDir" ]; then
				if  [ "$verbose" = true ]; then
					printf "The index already exists in %s and we do not need to copy the corpus \n" "$indexDir" >&2
				fi	
		else
			ls -1 $collection_path/MAGYAR2002 | xargs -i cp $collection_path/MAGYAR2002/{} ./corpus/;

			## create the collection.spec file needed for indexing purposes
			./terrier-4.0/bin/trec_setup.sh ./corpus

			## count the number of docs
			docs=$(wc -l < ./terrier-4.0/etc/collection.spec);
			##let "docs-=1";
			let docs=$docs-1;
			
			## check if the total number of docs to be indexes is correct
			if [ "$HU_CORPUS_SIZE" != "$docs" ]; then
				printf "The size (%s docs) of the current corpus does not correspond to the corpus size used for defining the baselines; indeed, the %s corpus must count %s documents.\n" "$docs" "$lang" "$HU_CORPUS_SIZE" >&2
				exit 1
			fi

		fi
       ;;    
    it) indexDir="$lang";
		
		if [ "$sl" = true ]; then

			stoplist=../../../../resources/"$lang"_sl.txt;
			indexDir="$indexDir"_Stopword;
		else
			stoplist="";
		fi

		if [ "$stm" = true ]; then
			stemmer=ItalianSnowballStemmer;
			indexDir="$indexDir"_Stemmer;
		else
			stemmer="";
		fi

		runTag="$indexDir"_"$rank_model";

		mkdir ../../runs/CLEF/terrier/"$lang";

		cd ../..
		runFile=$(pwd)/runs/CLEF/terrier/"$lang"/"$runTag".txt;
		cd systems/terrier
		indexScriptDir=$indexDir;
		indexDir=../../indexes/"$indexDir"; 
		indexTmpDir=./indexes/"$indexScriptDir";

	
		if [ -d "$indexTmpDir" ]; then
				if  [ "$verbose" = true ]; then
					printf "The index already exists in %s and we do not need to copy the corpus \n" "$indexDir" >&2
				fi	
		else
			ls -1 $collection_path/LASTAMPA1994 | xargs -i cp $collection_path/LASTAMPA1994/{} ./corpus/
			ls -1 $collection_path/AGZ1994 | xargs -i cp $collection_path/AGZ1994/{} ./corpus/
			ls -1 $collection_path/AGZ1995 | xargs -i cp $collection_path/AGZ1995/{} ./corpus/

			## create the collection.spec file needed for indexing purposes
			./terrier-4.0/bin/trec_setup.sh ./corpus

			## count the number of docs
			docs=$(wc -l < ./terrier-4.0/etc/collection.spec);
			##let "docs-=1";
			let docs=$docs-1;
			
			## check if the total number of docs to be indexes is correct
			if [ "$IT_CORPUS_SIZE" != "$docs" ]; then
				printf "The size (%s docs) of the current corpus does not correspond to the corpus size used for defining the baselines; indeed, the %s corpus must count %s documents.\n" "$docs" "$lang" "$IT_CORPUS_SIZE" >&2
				exit 1
			fi

		fi

       ;;
    nl) indexDir="$lang";

		if [ "$sl" = true ]; then

			stoplist=../../../../resources/"$lang"_sl.txt;
			indexDir="$indexDir"_Stopword;
		else
			stoplist="";
		fi

		if [ "$stm" = true ]; then
			stemmer=DutchSnowballStemmer;
			indexDir="$indexDir"_Stemmer;
		else
			stemmer="";
		fi

		runTag="$indexDir"_"$rank_model";

		mkdir ../../runs/CLEF/terrier/"$lang";

		cd ../..
		runFile=$(pwd)/runs/CLEF/terrier/"$lang"/"$runTag".txt;
		cd systems/terrier
		indexScriptDir=$indexDir;
		indexDir=../../indexes/"$indexDir"; 
		indexTmpDir=./indexes/"$indexScriptDir";

	
		if [ -d "$indexTmpDir" ]; then
				if  [ "$verbose" = true ]; then
					printf "The index already exists in %s and we do not need to copy the corpus \n" "$indexDir" >&2
				fi	
		else
			ls -1 $collection_path/ALGEMEEN1994 | xargs -i cp $collection_path/ALGEMEEN1994/{} ./corpus/;
			ls -1 $collection_path/ALGEMEEN1995 | xargs -i cp $collection_path/ALGEMEEN1995/{} ./corpus/;
			ls -1 $collection_path/NRC1994 | xargs -i cp $collection_path/NRC1994/{} ./corpus/;
			ls -1 $collection_path/NRC1995 | xargs -i cp $collection_path/NRC1995/{} ./corpus/;

			## create the collection.spec file needed for indexing purposes
			./terrier-4.0/bin/trec_setup.sh ./corpus

			## count the number of docs
			docs=$(wc -l < ./terrier-4.0/etc/collection.spec);
			##let "docs-=1";
			let docs=$docs-1;
			
			## check if the total number of docs to be indexes is correct
			if [ "$NL_CORPUS_SIZE" != "$docs" ]; then
				printf "The size (%s docs) of the current corpus does not correspond to the corpus size used for defining the baselines; indeed, the %s corpus must count %s documents.\n" "$docs" "$lang" "$NL_CORPUS_SIZE" >&2
				exit 1
			fi

		fi
       ;;  
    pt) indexDir="$lang";

		if [ "$sl" = true ]; then

			stoplist=../../../../resources/"$lang"_sl.txt;
			indexDir="$indexDir"_Stopword;
		else
			stoplist="";
		fi

		if [ "$stm" = true ]; then
			stemmer=PortogueseSnowballStemmer;
			indexDir="$indexDir"_Stemmer;
		else
			stemmer="";
		fi

		runTag="$indexDir"_"$rank_model";

		mkdir ../../runs/CLEF/terrier/"$lang";

		cd ../..
		runFile=$(pwd)/runs/CLEF/terrier/"$lang"/"$runTag".txt;
		cd systems/terrier
		indexScriptDir=$indexDir;
		indexDir=../../indexes/"$indexDir"; 
		indexTmpDir=./indexes/"$indexScriptDir";

	
		if [ -d "$indexTmpDir" ]; then
				if  [ "$verbose" = true ]; then
					printf "The index already exists in %s and we do not need to copy the corpus \n" "$indexDir" >&2
				fi	
		else
			ls -1 $collection_path/FOLHA1994 | xargs -i cp $collection_path/FOLHA1994/{} ./corpus/;
			ls -1 $collection_path/FOLHA1995 | xargs -i cp $collection_path/FOLHA1995/{} ./corpus/;
			ls -1 $collection_path/PUBLICO1994 | xargs -i cp $collection_path/PUBLICO1994/{} ./corpus/;
			ls -1 $collection_path/PUBLICO1995 | xargs -i cp $collection_path/PUBLICO1995/{} ./corpus/;

			## create the collection.spec file needed for indexing purposes
			./terrier-4.0/bin/trec_setup.sh ./corpus

			## count the number of docs
			docs=$(wc -l < ./terrier-4.0/etc/collection.spec);
			##let "docs-=1";
			let docs=$docs-1;
			
			## check if the total number of docs to be indexes is correct
			if [ "$PT_CORPUS_SIZE" != "$docs" ]; then
				printf "The size (%s docs) of the current corpus does not correspond to the corpus size used for defining the baselines; indeed, the %s corpus must count %s documents.\n" "$docs" "$lang" "$PT_CORPUS_SIZE" >&2
				exit 1
			fi

		fi
       ;;
    ru) indexDir="$lang";

		if [ "$sl" = true ]; then

			stoplist=../../../../resources/"$lang"_sl.txt;
			indexDir="$indexDir"_Stopword;
		else
			stoplist="";
		fi

		if [ "$stm" = true ]; then
			stemmer=RussianSnowballStemmer;
			indexDir="$indexDir"_Stemmer;
		else
			stemmer="";
		fi

		runTag="$indexDir"_"$rank_model";

		mkdir ../../runs/CLEF/terrier/"$lang";

		cd ../..
		runFile=$(pwd)/runs/CLEF/terrier/"$lang"/"$runTag".txt;
		cd systems/terrier
		indexScriptDir=$indexDir;
		indexDir=../../indexes/"$indexDir"; 
		indexTmpDir=./indexes/"$indexScriptDir";

	
		if [ -d "$indexTmpDir" ]; then
				if  [ "$verbose" = true ]; then
					printf "The index already exists in %s and we do not need to copy the corpus \n" "$indexDir" >&2
				fi	
		else
			ls -1 $collection_path/IZVESTIA1995 | xargs -i cp $collection_path/IZVESTIA1995/{} ./corpus/;

			## create the collection.spec file needed for indexing purposes
			./terrier-4.0/bin/trec_setup.sh ./corpus

			## count the number of docs
			docs=$(wc -l < ./terrier-4.0/etc/collection.spec);
			##let "docs-=1";
			let docs=$docs-1;
			
			## check if the total number of docs to be indexes is correct
			if [ "$RU_CORPUS_SIZE" != "$docs" ]; then
				printf "The size (%s docs) of the current corpus does not correspond to the corpus size used for defining the baselines; indeed, the %s corpus must count %s documents.\n" "$docs" "$lang" "$RU_CORPUS_SIZE" >&2
				exit 1
			fi

		fi
       ;;         
    sv) indexDir="$lang";

		if [ "$sl" = true ]; then

			stoplist=../../../../resources/"$lang"_sl.txt;
			indexDir="$indexDir"_Stopword;
		else
			stoplist="";
		fi

		if [ "$stm" = true ]; then
			stemmer=SwedishSnowballStemmer;
			indexDir="$indexDir"_Stemmer;
		else
			stemmer="";
		fi

		runTag="$indexDir"_"$rank_model";

		mkdir ../../runs/CLEF/terrier/"$lang";

		cd ../..
		runFile=$(pwd)/runs/CLEF/terrier/"$lang"/"$runTag".txt;
		cd systems/terrier
		indexScriptDir=$indexDir;
		indexDir=../../indexes/"$indexDir"; 
		indexTmpDir=./indexes/"$indexScriptDir";

	
		if [ -d "$indexTmpDir" ]; then
				if  [ "$verbose" = true ]; then
					printf "The index already exists in %s and we do not need to copy the corpus \n" "$indexDir" >&2
				fi	
		else
			ls -1 $collection_path/TT1994 | xargs -i cp $collection_path/TT1994/{} ./corpus/;
			ls -1 $collection_path/TT1995 | xargs -i cp $collection_path/TT1995/{} ./corpus/;

			## create the collection.spec file needed for indexing purposes
			./terrier-4.0/bin/trec_setup.sh ./corpus

			## count the number of docs
			docs=$(wc -l < ./terrier-4.0/etc/collection.spec);
			##let "docs-=1";
			let docs=$docs-1;
			
			## check if the total number of docs to be indexes is correct
			if [ "$SV_CORPUS_SIZE" != "$docs" ]; then
				printf "The size (%s docs) of the current corpus does not correspond to the corpus size used for defining the baselines; indeed, the %s corpus must count %s documents.\n" "$docs" "$lang" "$sv_CORPUS_SIZE" >&2
				exit 1
			fi

		fi
       ;;   
  esac

## create the terrier.properties file
create_terrier_properties()
{

     # initialize a local var
     local file="./terrier-4.0/etc/terrier.properties"

     # check if file exists. 
     if [ ! -f "$file" ] ; then
         # if not create the file
         touch "$file"
     else
     	rm "$file"
     	touch "$file"
     fi

	echo "#which collection to use to index?
#or if you're indexing nonEnglish collections:
#trec.collection.class=TRECUTFCollection
tokeniser=UTFTokeniser
trec.encoding=UTF-8

#default controls for query expansion
querying.postprocesses.order=QueryExpansion
querying.postprocesses.controls=qe:QueryExpansion
#default controls for the web-based interface. SimpleDecorate
#is the simplest metadata decorator. For more control, see Decorate.
querying.postfilters.order=SimpleDecorate,SiteFilter,Scope
querying.postfilters.controls=decorate:SimpleDecorate,site:SiteFilter,scope:Scope

#default and allowed controls
querying.default.controls=
querying.allowed.controls=scope,qe,qemodel,start,end,site,scope

#document tags specification
#for processing the contents of
#the documents, ignoring DOCHDR
TrecDocTags.doctag=DOC
TrecDocTags.idtag=DOCNO
TrecDocTags.skip=DOCID
#set to true if the tags can be of various case
TrecDocTags.casesensitive=false" >> "$file"

	if [ "$lang" = "fr" ]; then
		echo "indexer.meta.forward.keys=DOCNO
		indexer.meta.forward.keylens=30" >> "$file"

	fi

	echo "#query tags specification
TrecQueryTags.doctag=topic
TrecQueryTags.idtag=identifier
TrecQueryTags.process=topic,identifier,title,description
TrecQueryTags.skip=<?xml,narrative" >> "$file"

      printf "stopwords.filename=%s\n" "$stoplist" >> "$file"

      if [ "$sl" = true -a "$stm" = true ]; then
			 printf "termpipelines=%s,%s\n" "Stopwords" "$stemmer" >> "$file"
	  elif [ "$sl" = true -a "$stm" = false ]; then
			printf "termpipelines=%s\n" "Stopwords">> "$file"
      elif [ "$sl" = false -a "$stm" = true ]; then
			printf "termpipelines=%s\n" "$stemmer">> "$file"
	  else		
	  		printf "termpipelines=\n">> "$file"
	  fi
     
     printf "terrier.index.path=%s\n" "$indexDir">> "$file"

     
 }

if  [ "$verbose" = true ]; then
	printf "Creating the terrier.properties file \n"
fi

# execute it
create_terrier_properties



if [ -d "$indexTmpDir" ]; then
	if  [ "$verbose" = true ]; then
		printf "The index already exists in %s \n" "$indexDir" >&2
	fi	
else
	if  [ "$verbose" = true ]; then
		printf "Indexing the documents for the %s corpus and storing it in %s \n" "$lang" "$indexDir" >&2
	fi

	mkdir "$indexTmpDir";

	## create the index
	./terrier-4.0/bin/trec_terrier.sh -i

fi

## DELETE the CORPUS
rm -R ./corpus;


if  [ "$verbose" = true ]; then
	printf "Performing the retrieval with the ranking model %s \n" "$rank_model" >&2
fi

## do the retrieval
./terrier-4.0/bin/trec_terrier.sh -r -Dtrec.model=$rank_model -Dtrec.topics=$topics -Dtrec.results.file=$runFile -Dtrec.runtag=$runTag

## do the evaluation
## compile trec_eval
#make ./trec_eval.9.0/

## store the evaluation results in the results dir
../../eval/trec_eval.9.0/trec_eval -q -c -M1000 $qrels $runFile>../../results/CLEF/terrier/"$lang"/"$runTag".txt
