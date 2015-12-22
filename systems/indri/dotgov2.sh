#!/bin/bash
set -eu

# 2015 July 22 - James Valenti/Jamie Callan Carnegie Mellon University

# location of the index (where it is or where it should be created)
# ** CHOOSE WISELY, THE INDEX CAN BE QUITE LARGE(ish) **

INDEX_PATH=./indri_index/

#
# query parameters
#

# number of results to return for each query
QPARAM_COUNT=1000
# rules
QPARAM_RULE_DIRICHLET_MU_BOW=1000
QPARAM_RULE_DIRICHLET_MU_SDM=3000

# number of threads to use for the queries		
# best results will be dependant upon the machine it runs on
number_of_threads=1 

# provides GOV2_LOCATION, TOPICS_QRELS and TREC_EVAL
# (also builds trec_Eval if needed)
source ../common.sh

# if a glob doesnt match, substitute null
shopt -s nullglob

#
# indri
# 

INDRI_DIR=(indri-[0-9].[0-9])
INDRI_TAR=(indri-[0-9].[0-9].tar.gz)

# indri is downloaded from this URL
# the latest file is here:
#URL="http://sourceforge.net/projects/lemur/files/latest/download?source=files"
URL="http://downloads.sourceforge.net/project/lemur/lemur/indri-5.9/indri-5.9.tar.gz"

# (NOTE: using arrays here because glob could have more than one match)

# if there is more than one indri present, exit
if [[ ${#INDRI_DIR[@]} -gt 1 ]]
then
	echo "multiple existing indri directories found: ${INDRI_DIR[@]}"
	echo "don't know which to use, delete all or leave just one"
	exit
fi

if [[ ${#INDRI_DIR[@]} -eq 0 ]]; then

	echo "no indri directory found"

	if [[ ${#INDRI_TAR[@]} -eq 0 ]]
	then 
		echo "getting indri from ${URL}..."
		wget "$URL"
	fi

	INDRI_TAR=(indri-[0-9].[0-9].tar.gz)

	if [[ ${#INDRI_TAR[@]} -eq 1 ]]
	then 
		echo "expanding archive ${INDRI_TAR[0]}"
		tar -zxf ${INDRI_TAR[0]}
		echo "configuring indri..."
		INDRI_DIR=(indri-[0-9].[0-9])
		cd ${INDRI_DIR}
		./configure
		echo "makeing indri..."
		make
		cd ..
	else
		echo "multiple indri archives (tar.gz) found: ${#INDRI_TAR[@]}"
		echo "don't know which to use, delete all or leave jsut one"
		exit
	fi
fi

INDRI_DIR=(indri-[0-9].[0-9])

INDRI="./$INDRI_DIR/runquery/IndriRunQuery"
BUILD_INDEX="$INDRI_DIR/buildindex/IndriBuildIndex"

echo "using indri $INDRI"

# build index if not already:
LOG_FILE=./build_index.log

query_results_folder=./query_results
score_results_folder=./scores
results_file=./results
rm -f ${results_file}/*

# if the index does not exist, then build it

if [ ! -d ${INDEX_PATH}/index ]
then
	START=$(date +%s.%N)
	echo "building indri index at ${INDEX_PATH} from corpus at ${GOV2_LOCATION} see logs ${LOG_FILE} for details"
	${BUILD_INDEX} -memory=30G -storeDocs=false -index=${INDEX_PATH} -corpus.path=${GOV2_LOCATION} -corpus.class=trecweb -stemmer.name=krovetz -stopper.word=${INDRI_DIR}/site-search/stopwords 1> >(tee ${LOG_FILE}.stdout) 2> >(tee ${LOG_FILE}.stderr) 
	END=$(date +%s.%N)
	INDEX_BUILD_TIME=$(echo "$END - $START" | bc)
	echo "finished building index..."
	echo "index build time :: $INDEX_BUILD_TIME seconds" >> ${results_file}
else
	echo "using existing index at ${INDEX_PATH}/index"
fi

TMPDIR=./tmp
if [ ! -d ${TMPDIR} ]
then
	echo "making a temp directory ${TMPDIR}"
	mkdir ${TMPDIR}
fi

queries_folder=./queries
if [ ! -d ${queries_folder} ]
then
	echo "making queries directory ${queries_folder}..."
	mkdir ${queries_folder}
fi


# comment this out to not overwrite previous results
rm -f ${query_results_folder}/*

if [ ! -d ${query_results_folder} ]
then
	echo "making run results directory ${query_results_folder}..."
	mkdir ${query_results_folder}
else
	echo "found an existing query results directory ${query_results_folder}..."
fi


if [ ! -d ${score_results_folder} ]
then
	echo "making score results directory ${score_results_folder}..."
	mkdir ${score_results_folder}
else
	echo ""
fi

for queries in "701-750" "751-800" "801-850"
do
	echo "working on query set ${queries} ..."

	query_results_file_bow=${query_results_folder}/bow_queries_${queries}
	query_results_file_sdm=${query_results_folder}/sdm_queries_${queries}
	
	score_file_bow=${score_results_folder}/trec-eval_bow_queries_${queries}
	score_file_sdm=${score_results_folder}/trec-eval_sdm_queries_${queries}

	# if the query file is missing for a query series (ie 701-750), then run the query and evaluation 

	if [ ! -f ${query_results_file_bow} ] || [ ! -f ${query_results_file_sdm} ]
	then

		if [ ! -d ${queries_folder} ]
		then
			echo "making queries directory ${queries_folder}..."
			mkdir ${queries_folder}
		else
			echo "using existing queries directory ${queries_folder}"
		fi
		
		# create the queries from <num> and <title> fields in the topics file

		topics_file=$TOPICS_QRELS/topics.${queries}.txt
		num_file=${TMPDIR}/num_$queries
		titles_file=${TMPDIR}/titles_$queries
		cat ${topics_file} | grep "<num>"   | awk '{print substr ($0, index($0,$3))}'  > ${num_file}
		cat ${topics_file} | grep "<title>" | awk '{print substr ($0, index($0,$2))}'  > ${titles_file}
		
		# remove periods, single quotes, ampersands and slashes
		stemmed_titles_file=${TMPDIR}/stemmed_titles_$queries
		cat ${titles_file} | sed "s/[*.]//g" | sed "s/[*']//g" | sed "s/[*&]//g" | sed "s/[*/]//g" > ${stemmed_titles_file}

		# create  BAG OF WORDS queries
		bow_queries_file=${TMPDIR}/bow_queries_${queries}
		paste -d ":" ${num_file} ${stemmed_titles_file} > ${bow_queries_file}
	
		# create SEQUENTIAL DEPENDANCY MODEL queries
		sdm_queries_file=${TMPDIR}/sdm_queries_${queries}
		bow2sdm_queries_file=${TMPDIR}/bow2sdm_queries_${queries}
		perl dm.pl ${stemmed_titles_file} >${bow2sdm_queries_file}
		paste -d ":" ${num_file} ${bow2sdm_queries_file} > ${sdm_queries_file}
		
		# create the XML parameter files. These are the acutal queries that will be run by indri
		# ie
		# <paramerters>
		#	<index>${INDEX_PATH}/index</index>
		#	<trecFormat>true</trecFormat>
		#	<count>1000</count>		
		#	<threads>number_of_threads</threads>
		#	<query>
		#		<number>701</number>
		#		<text>US oil crisis</text>
		#	</query>
		#	...
		#	<query> ... </query>
		# </parameters>

		# create BOW parameter file
	

		bow_param_file=${queries_folder}/param_bow_queries_${queries}
		echo -e "<parameters>\n"\
		"\t<index>${INDEX_PATH}</index>\n"\
		"\t<trecFormat>true</trecFormat>\n"\
		"\t<rule>dirichlet:${QPARAM_RULE_DIRICHLET_MU_BOW}</rule>\n"\
		"\t<count>${QPARAM_COUNT}</count>" >${bow_param_file}
	 	echo -e "\<threads>${number_of_threads}</threads>">>${bow_param_file}
	
		while IFS='' read -r line || [[ -n $line ]]
		do
			# (the query file contains each query in the form query_num:query, one per line)
			# match everything up to ':'
			number=`echo "$line" | sed "s/:.*$//"`
			# match everything from : onward
			text=`echo "$line" | sed "s/[^:]*//"`
			# remove the first character (leading :)
			text=`echo "$text" | sed "s/.\(.*\)/\1/"`
			
			echo -e "\t<query>\n"\
			"\t\t<number>${number}</number>\n"\
			"\t\t<text>${text}</text>\n"\
			"\t</query>" >>${bow_param_file}

		done  < ${bow_queries_file}

		echo -e "</parameters>" >>${bow_param_file}

		# create SDM parameter file

		sdm_param_file=${queries_folder}/param_sdm_queries_${queries}
		echo -e "<parameters>\n"\
		"\t<index>${INDEX_PATH}</index>\n"\
		"\t<trecFormat>true</trecFormat>\n"\
		"\t<rule>dirichlet:${QPARAM_RULE_DIRICHLET_MU_SDM}</rule>\n"\
		"\t<count>${QPARAM_COUNT}</count>" >${sdm_param_file}
		echo -e "\t<threads>${number_of_threads}</threads>" >>${sdm_param_file}
		
		while IFS='' read -r line || [[ -n $line ]]
		do
			# (the query file contains each query in the form query_num:query, one per line)
			# match everything up to ':'
			number=`echo "$line" | sed "s/:.*$//"`
			# match everything from : onward
			text=`echo "$line" | sed "s/[^:]*//"`
			# remove the first character (leading :)
			text=`echo "$text" | sed "s/.\(.*\)/\1/"`
			
			echo -e "\t<query>\n"\
			"\t\t<number>${number}</number>\n"\
			"\t\t<text>${text}</text>\n"\
			"\t</query>" >>${sdm_param_file}

		done  < ${sdm_queries_file}

		echo -e "</parameters>" >>${sdm_param_file}

		# run the queries
		
		echo "running BOW ${queries} queries ${bow_param_file} with ${number_of_threads} threads. Writing results to ${query_results_file_bow}"
		START=$(date +%s.%N)
		${INDRI} ${bow_param_file} >${query_results_file_bow}
		END=$(date +%s.%N)
		BOW_RUN_TIME=$(echo "$END - $START" | bc)
		echo "run time :: $BOW_RUN_TIME seconds, ${number_of_threads} threads"

		echo "running SDM ${queries} queries ${sdm_param_file} with ${number_of_threads} threads. Writing results to ${query_results_file_sdm}"
		START=$(date +%s.%N)
		${INDRI} ${sdm_param_file} >${query_results_file_sdm}
		END=$(date +%s.%N)
		SDM_RUN_TIME=$(echo "$END - $START" | bc)
		echo "run time :: $SDM_RUN_TIME seconds, ${number_of_threads} threads"

		# score the query results
		
		qrel_file=$TOPICS_QRELS/qrels.${queries}.txt
		
		echo "scoring BOW ${queries} file ${query_results_file_bow} with ${qrel_file} and writing results to ${score_file_bow}"
		$TREC_EVAL ${qrel_file} ${query_results_file_bow} >${score_file_bow}

		echo "scoring SDM ${queries} file ${query_results_file_sdm} with ${qrel_file} and writing results to ${score_file_sdm}"
		$TREC_EVAL ${qrel_file} ${query_results_file_sdm} >${score_file_sdm}

		# save relevant info in results file
		# for extensive benchmarking, it may be desireable to place certain  trec-eval measurements in the results file
		# (adapt as needed)
		echo "recording results..."
		echo -e "BOW ${queries} dirichlet mu=${QPARAM_RULE_DIRICHLET_MU_BOW}\n"\
		     "run time (seconds) :: $BOW_RUN_TIME" >>${results_file}
		grep "^map" ${score_file_bow} >>${results_file}
		echo -e "SDM ${queries} dirichlet mu=${QPARAM_RULE_DIRICHLET_MU_SDM}\n"\
		     "run time (seconds) :: $SDM_RUN_TIME" >>${results_file}
		grep "^map" ${score_file_sdm} >>${results_file}
	else
		echo "found exisitng BOW and SDM run results for ${queries} skipping..."
	fi
done

echo "trec-eval results are in ${score_results_folder}"
cat ${results_file}
# more removal of intermediate files can be done here
# (-f so there are no error messages if the folder does not exist)
rm -fr ${TMPDIR}
echo "~fin~"
