# .GOV2 Comparisons
What follows is an initial comparison of selected information retrieval systems on the .GOV2 collection using scripts provided by authors/leading contributors of those systems. The systems are listed in alphabetical order.

## Indexing
Two metrics for indexing are reported below: the size of the generated index, and the time taken to generate that index. Index sizes are calculated by `du -abc` on the relevant folders/files (1GB = 1000000000B).

System  | Type               |  Size |    Time | Terms | Postings |  Tokens
:-------|:-------------------|------:|--------:|------:|---------:|--------:
ATIRE   | Count              | 12 GB |     41m | 39.9M |     7.0B |   26.5B
ATIRE   | Count + Quantized  | 15 GB |     59m | 39.9M |     7.0B |   26.5B
Galago  | Count              | 15 GB |  6h 32m | 36.0M |     5.7B |       -
Galago  | Positions          | 48 GB | 26h 23m | 36.0M |     5.7B |   22.3B
Indri   | Positions          | 92 GB |  6h 42m | 39.2M |        - |   23.5B
JASS    | ATIRE Quantized    | 21 GB |  1h 03m | 39.9M |     7.0B |   26.5B
Lucene  | Count              | 11 GB |  1h 36m | 72.9M |     5.5B |       -
Lucene  | Positions          | 40 GB |  2h 00m | 72.9M |     5.5B |   17.8B
MG4J    | Count              |  8 GB |  1h 46m | 34.9M |     5.5B |       -
MG4J    | Positions          | 37 GB |  2h 11m | 34.9M |     5.5B |   23.1B
Terrier | Count              | 10 GB |  8h 06m | 15.3M |     4.6B |       -
Terrier | Count (inc direct) | 18 GB | 18h 13m | 15.3M |     4.6B |       -
Terrier | Positions          | 36 GB |  9h 44m | 15.3M |     4.6B |   16.2B

###### ATIRE
+ The quantized index pre-calculates the BM25 scores at indexing time and stores these instead of term frequencies, more about the quantization in ATIRE can be found in [Crane et al. (2013)](http://dl.acm.org/citation.cfm?id=2507860).
  + The quantization is performed single threaded although easily parallelized.
+ Both indexes were stemmed using an s-stripping stemmer.
+ Both indexes were pruned of SGML tags, used for typically unused search time features.
+ Both indexes postings lists are stored impact ordered, with docids being compressed using variable-byte compression after being delta encoded.

###### Indri
+ The index contains an inverted index and DocumentTerm vectors (a forward index).
+ Stopwords were removed and terms were stemmed with the Krovetz stemmer.

###### JASS
+ JASS creates a transformation of ATIRE's quantized indexes.
+ The indexing time includes the time taken for ATIRE to generate the index.

###### MG4J
+ MG4J does not use gap-based compression, but rather [quasi-succinct indices](http://vigna.di.unimi.it/papers.php#VigQSI).
+ After extracting text from HTML, all maximal subsequences of alphanumerical characters are 
stemmed using the Porter2 stemmer and indexed.

###### Terrier
+ Docids are compressed using gamma delta-gaps and the term frequencies using unary.
+ Positions are compressed using gamma delta-gaps.
+ All indexes are built using the singlepass indexer, except the index that includes a direct file, for which we used the slower traditional indexer.


## Retrieval
Both retrieval efficiency (by query latency) and effectiveness (MAP@1000) were measured on three query sets: 701-750, 751-800, and 801-850.

### Retrieval Models

###### ATIRE
+ ATIRE uses a modified version of BM25, described [here](http://www.cs.otago.ac.nz/homepages/andrew/papers/2012-1.pdf).
+ Searching was done using top-k search also described in the above paper.
  + This is not early termination, all documents for all terms in the query still get scored.
+ BM25 parameters were set to the default for ATIRE, `k1=0.9 b=0.4`.
+ Searching of a stemmed index automatically does a stemmed search.
+ Only stopping of tags was performed, this has no effect on search.

###### Galago
+ QL is our baseline query-likelihood (bag-of-words) model with dirichlet smoothing and default mu parameters.
+ SDM is our implementation of the [Markov-Random-Field model for Term Dependencies (Metzler and Croft, 2005)](http://dl.acm.org/citation.cfm?id=1076115).
    + The features used are: unigrams, bigrams, and unordered windows of size 8.
+ Both of these models require parameter tuning for best performance. No stopping was done for these models.

###### Indri
+ version 5.9
+ QL is our baseline query-likelihood (bag-of-words) model with dirichlet smoothing and default mu parameters.
+ SDM is our implementation of the [Markov-Random-Field model for Term Dependencies (Metzler and Croft, 2005)](http://dl.acm.org/citation.cfm?id=1076115).
    + The features used are: unigrams, bigrams, and unordered windows of size 8.
    + mu = 3000
+ Both of these models require parameter tuning for best performance.

###### JASS
+ JASS performs early termination after the specified number of postings have been process.

###### Lucene
+ Lucene 5.2.1
+ BM25 similarity with parameters same as ATIRE (k1=0.9, b=0.4).
+ [EnglishAnalyzer](https://lucene.apache.org/core/5_2_1/analyzers-common/org/apache/lucene/analysis/en/EnglishAnalyzer.html) shipped with Lucene used, with all default settings.
+ Positions index built with [TextField](https://lucene.apache.org/core/5_2_1/core/org/apache/lucene/document/TextField.html). Count index built with [custom field](https://github.com/lintool/IR-Reproducibility/blob/master/systems/lucene/ingester/src/main/java/luceneingester/NoPositionsTextField.java) that doesn't store positions.

###### MG4J
+ Model B is described in [Boldi et al. (2006)](http://trec.nist.gov/pubs/trec15/papers/umilano.tera.final.pdf).
+ Model B+ is very similar to Model B, but it uses positions to retrieve first documents satisfying
each conjunctive subquery within a window equal to two times the number of terms in the query.
+ The BM25 column shows a baseline based on the BM25 score function applied to the results of the title query treated as a bag of words.

###### Terrier
+ BM25 uses the default settings recommended by Robertson.
+ DPH is a hypergeometric parameter-free model from the Divergence from Randomness family.
+ Query expansion (QE) is performed using the Bo1 Divergence from Randomness query expansion model, 10 terms were added from 3 pseudo-relevance feedback documents.
+ The proximity approach uses a DFR model called [pBiL](http://dl.acm.org/citation.cfm?id=1277937), using sequential dependencies.

### Retrieval Latency
The table below shows the average search time across queries by query set. The average is taken from three runs of the queries. The search times were taken from the internal reporting of each systems.

System  | Model          | Index               | Topics 701-750 | Topics 751-800 | Topics 801-850 | Combined
:-------|:---------------|---------------------|---------------:|---------------:|---------------:|---------:
ATIRE   | BM25           | Count               |          132ms |          175ms |          131ms |    146ms
ATIRE   | Quantized BM25 | Count + Quantized   |           91ms |           93ms |           85ms |     89ms
Galago  | QL             | Count               |          773ms |          807ms |          651ms |    743ms
Galago  | SDM            | Positions           |         4134ms |         5989ms |         4094ms |   4736ms
Indri   | QL             | Positions           |         1252ms |         1516ms |         1163ms |   1310ms
Indri   | SDM            | Positions           |         7631ms |        13077ms |         6712ms |   9140ms
JASS    | 1B Postings    | Count               |           53ms |           54ms |           48ms |     51ms
JASS    | 2.5M Postings  | Count               |           30ms |           28ms |           28ms |     28ms
Lucene  | BM25           | Count               |          120ms |          107ms |          125ms |    118ms
Lucene  | BM25           | Positions           |          121ms |          109ms |          127ms |    119ms
MG4J    | BM25           | Count               |          348ms |          245ms |          266ms |    287ms
MG4J    | Model B        | Count               |           39ms |           48ms |           36ms |     41ms
MG4J    | Model B+       | Positions           |           91ms |           92ms |           75ms |     86ms
Terrier | BM25           | Count               |          363ms |          287ms |          306ms |    319ms
Terrier | DPH            | Count               |          627ms |          421ms |          416ms |    488ms
Terrier | DPH + Bo1 QE   | Count (inc. direct) |         1845ms |         1422ms |         1474ms |   1580ms
Terrier | DPH + Prox SD  | Positions           |         1434ms |         1034ms |         1039ms |   1169ms

##### Extra Notes
###### Terrier
Terrier's indexing as of v4.0 is comparably slow. An inspection of indexing using a profiler found that an [inefficiency had been introduced](http://terrier.org/issues/browse/TR-340). We expect to trivially fix this for the next version 4.1 release.

###### Galago
Galago's SDM calculates expensive ordered and unordered window features, which explains part of the extreme difference. Even Galago's QL, simple unigram model is quite slow in comparison to other engines. We are investigating the bottleneck.

### Retrieval Effectiveness
The systems generated run files to be consumed by the `trec_eval` tool. Each system was evaluated on the top 1000 results for each query, and the table below shows the MAP scores for the systems.

System  | Model          | Index              | Topics 701-750 | Topics 751-800 | Topics 801-850 | Combined
:-------|:---------------|--------------------|---------------:|---------------:|---------------:|---------:
ATIRE   | BM25           | Count              |         0.2616 |         0.3106 |         0.2978 |   0.2902
ATIRE   | Quantized BM25 | Count + Quantized  |         0.2603 |         0.3108 |         0.2974 |   0.2897
Galago  | QL             | Count              |         0.2776 |         0.2937 |         0.2845 |   0.2853
Galago  | SDM            | Positions          |         0.2726 |         0.2911 |         0.3161 |   0.2934
Indri   | QL             | Positions          |         0.2597 |         0.3179 |         0.2830 |   0.2870
Indri   | SDM            | Positions          |         0.2621 |         0.3086 |         0.3165 |   0.2960
JASS    | 1B Postings    | Count              |         0.2603 |         0.3109 |         0.2972 |   0.2897
JASS    | 2.5M Postings  | Count              |         0.2579 |         0.3053 |         0.2959 |   0.2866
Lucene  | BM25           | Count              |         0.2684 |         0.3347 |         0.3050 |   0.3029
Lucene  | BM25           | Positions          |         0.2684 |         0.3347 |         0.3050 |   0.3029
MG4J    | BM25           | Count              |         0.2640 |         0.3336 |         0.2999 |   0.2994
MG4J    | Model B        | Count              |         0.2469 |         0.3207 |         0.3003 |   0.2896
MG4J    | Model B+       | Positions          |         0.2322 |         0.3179 |         0.3257 |   0.2923
Terrier | BM25           | Count              |         0.2432 |         0.3039 |         0.2614 |   0.2697
Terrier | DPH            | Count              |         0.2768 |         0.3311 |         0.2899 |   0.2994
Terrier | DPH + Bo1 QE   | Count (inc direct) |         0.3037 |         0.3742 |         0.3480 |   0.3422
Terrier | DPH + Prox SD  | Positions          |         0.2750 |         0.3297 |         0.2897 |   0.2983

##### Statistical Analysis

**TODO:** Need to run statistical analyses.
