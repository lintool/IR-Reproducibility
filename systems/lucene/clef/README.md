# Apache Lucene - CLEF

*lucene-clef* provides indexing and retrieval functionalities for the CLEF Test Collections through the
[Apache Lucene](https://lucene.apache.org/core/) (version [5.2.1](https://lucene.apache.org/core/5_2_1/index.html))
library.

### Experiments on CLEF Test Collections

The experiments can be replicated by the script [clef_experiments.sh](../clef_experiments.sh).
An example of usage of the script is the following:

`./clef_experiments.sh -l it -cp /media/CLEF/corpora -stm y -sl y -r BM25`

where the meaning of the options is:
- *-l*  the language of the test collection (e.g. *it*)
- *-cp* the path to the directory where the document corpora are stored (e.g. */media/CLEF/corpora*)
- *-stm* enable (-stm y) or disable (-stm n) the stemmer
- *-sl* enable (-sl y) or disable (-sl n) the use of the stoplist
- *-r* the ranking model (e.g. BM25)

The current version of *lucene-clef* supports the following models:
- BM25

The script [clef.sh](../clef.sh) iterates over the diverse set of options stored in the [clef_runs](../clef_runs) file
(one combination of options per line) and call the [clef_experiments.sh](../clef_experiments.sh) using each option set.
The lines in the [clef_runs](../clef_runs) have the following format:

`it	y	y	BM25`

where the options are separated by tabs; the first option refer to the language, the second to the stemmer, the third
to the stoplist usage and the last one to the model. The last line of the [clef_runs](../clef_runs) should be empty.