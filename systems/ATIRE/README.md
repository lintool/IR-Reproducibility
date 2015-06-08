ATIRE
=====

The ATIRE makefile has a set of options that have been already preselected to provide good performance for indexing.

The script `dotgov2.sh` provides a script that will clone the required repositories, build the system, index and search all the query sets.

Indexing
--------

The first two arguments to the indexer simply specify a progress output every `n` documents (`-N<n>`, in this case one million), and to print statistics at the conclusion of the indexing.

The next argument specifies the format of the documents. In this case it has been set to recursively find and parse documents according to the TREC format; treating everything between `<DOC>` and `</DOC>`, inclusive, as indexable content. The content between `<DOCNO>` and `</DOCNO>` contains the document id. The exception to this are terms that appear in `SMGL` tags, of which only the tag itself is stored uppercased to allow for focussed retrieval. A term is defined as either a sequence of alpha characters, or a sequence of numeric characters, the definitions of which come from Unicode version 6.0.

As the .gov2 collection is supposed to contain only ASCII data, the `-iscrub:an` option is specified. This option will replace the `NUL` character, and other non-ASCII characters with a space. This prevents malformed data getting into the index. No other content filtering other than this is applied.

Finally, the indexer uses an s-stripping stemmer.

The script generates two indexes using these options, the first is a quantized index, which pre-calculates the retrieval scores and stores them in the index rather than having to be calculated at search time. The `-Q` parameter identifies the ranking function, and the `-q` parameter stores the quantized values. The second index is missing these parameters as it is an unquantized index.

Finally are a number of arguments to the indexer. These determine the locations for the recursive searching to take place. In the case of the gov2 script, each sub-folder of the gov2 collection is recursively searched for files matching the pattern `*.gz`. The number of arguments to the indexer determines one of the degrees of parallelism, the other is static. This combination has been shown empirically to perform better than other combinations.

Searching
---------

The search is performed to completion for both indexes, for all query sets. A run file is generated for each query set, with the top-1000 results presented, which can be evaluated using traditional TREC tools.

The first search command is targeted at high efficiency. To do this it uses the quantized index (specified with `-findex <index filename>`), which sets the ranking function internally.

Counter intuitively, the top-k parameter is not used for the speed baseline, as our experiments suggest that at high values of `k` this has an adverse affect on speed. The second argument to the efficiency baseline is the `-M` flag, which tells the search program to load the entire index into memory at startup.

The second search command is targeted at high effectiveness. It uses the default index filename (`index.aspt`), which is generated by the non-quantized indexer.

The ranking function for the second search is left to the default BM25 implementation with ATIRE, with the default parameters of `k1=0.9, b=0.4`.

The second parameter, `-Qr`, to the effectiveness search specifies to use Rocchio blind relevance feedback. There are optional parameters to this argument to specify the number of document to analyse, and the number of terms to extract. These are left at the defaults of `17` documents, and `5` terms.

The remainder of the arguments are shared among both searches. These arguments specify to print statistics (`-sa`), and setup the query type (`-QN:t` -- `<title>` fields from a TREC topic file), the file containing the queries (`-q <filepath>`), and options related to generating the run file. Each run file is named `atire.<query set>.<speed|precision>.txt`, and the search statistics are redirected to `<query set>.<speed|precision>.search_stats.txt`.