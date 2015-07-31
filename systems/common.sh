GOV2_LOCATION=/media/Gov2/data
CW09B_LOCATION=/media/ClueWeb09b/ClueWeb09_English_1
CW12B_LOCATION=/media/ClueWeb12-B13/DiskB

TOPICS_QRELS=../../topics-and-qrels/
TREC_EVAL=../../eval/trec_eval.9.0/trec_eval
SAP_EVAL=../../eval/statAP_MQ_eval_v3.pl
GD_EVAL=../../eval/gdeval

# define JAVA_HOME for those tools that need it
export JAVA_HOME='/usr/lib/jvm/java-8-oracle/'

# Build trec eval if it has not been
if [[ ! -f ${TREC_EVAL} ]]; then
	tar xzf ../../eval/trec_eval.9.0.tar.gz -C ../../eval
	make -C ../../eval/trec_eval.9.0/
fi

# Get statMAP eval tool for the 2009 queries
if [[ ! -f ${SAP_EVAL} ]]; then
	curl http://trec.nist.gov/data/web/09/statAP_MQ_eval_v3.pl > ${SAP_EVAL}
	chmod +x ${SAP_EVAL}
fi

# Get the gdeval tool for ERR, nDCG
# This is the latest version I could find
if [[ ! -f ${GD_EVAL} ]]; then
	curl https://raw.githubusercontent.com/trec-web/trec-web-2014/master/src/eval/gdeval.pl > ${GD_EVAL}
	chmod +x ${GD_EVAL}
fi
