GOV2_LOCATION=/media/Gov2/data
CW09B_LOCATION=/media/ClueWeb09/ClueWeb09_English_1
CW12B_LOCATION=/media/ClueWeb12/DiskB

TOPICS_QRELS=../../topics-and-qrels/
TREC_EVAL=../../eval/trec_eval.9.0/trec_eval

# define JAVA_HOME for those tools that need it
export JAVA_HOME='/usr/lib/jvm/java-8-oracle/'

# Build trec eval if it has not been
if [[ ! -f ${TREC_EVAL} ]]; then
	tar xzf ../../eval/trec_eval.9.0.tar.gz -C ../../eval
	make -C ../../eval/trec_eval.9.0/
fi
