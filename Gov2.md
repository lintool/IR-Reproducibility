# .GOV2 Comparisons
What follows is an initial comparison of selected information retrieval systems on the .GOV2 collection using scripts provided by authors/leading contributors of those systems. The systems are listed in alphabetical order.

## Indexing
Two metrics for indexing are reported below: the size of the generated index, and the time taken to generate that index. Index sizes are calculated by `du -abc` on the relevant folders/files (1GB = 1000000000B).

System  | Type              |  Size |    Time | Terms | Postings | Tokens |
:-------|:------------------|------:|--------:|------:|---------:|--------:
ATIRE   | Count             | 12 GB |     46m |       |          |        |
ATIRE   | Count + Quantized | 15 GB |     56m |       |          |        |
Galago  | Count             | 15 GB |  6h 32m |       |          |        |
Galago  | Positions         | 48 GB | 26h 33m |       |          |        |
Indri   | Positions         | 92 GB |  6h 40m | 39.2M |    23.5G |        |
JASS    | ATIRE Quantized   | 21 GB |     58m |       |          |        |
Lucene  | Count             | 12 GB |  1h 25m |       |          |        |
Lucene  | Positions         | 40 GB |  1h 35m |       |          |        |
MG4J    | Count             |  8 GB |  1h 25m | 34.9M |     5.5G |        |
MG4J    | Positions         | 37 GB |  2h 06m | 34.9M |     5.5G |  23.1G |
Terrier | Count             | 10 GB |  8h 04m | 15.3M |     4.6G |  16.2G |
Terrier | Count (inc direct)| 19 GB | 18h 16m | 15.3M |     4.6G |  16.2G |
Terrier | Positions         | 36 GB |  9h 37m | 15.3M |     4.6G |  16.2G |

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
+ version 5.3
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

System  | Model          | Index               | Topics 701-750 | Topics 751-800 | Topics 801-850
:-------|:---------------|---------------------|---------------:|---------------:|--------------:
ATIRE   | BM25           | Count               |          131ms |          176ms |          131ms
ATIRE   | Quantized BM25 | Count + Quantized   |           91ms |           93ms |           85ms
Galago  | QL             | Count               |          769ms |          820ms |          661ms
Galago  | SDM            | Positions           |         4134ms |         6091ms |         3943ms
Indri   | QL             | Positions           |         1252ms |         1516ms |         1163ms
Indri   | SDM            | Positions           |         7631ms |        13077ms |         6712ms
JASS    | 1B Postings    | Count               |           47ms |           50ms |           45ms
JASS    | 2.5M Postings  | Count               |           26ms |           25ms |           25ms
Lucene  | BM25           | Count               |          148ms |          109ms |          141ms
Lucene  | BM25           | Positions           |          119ms |          111ms |          118ms
MG4J    | BM25           | Count               |          362ms |          257ms |          267ms
MG4J    | Model B        | Count               |           37ms |           48ms |           36ms
MG4J    | Model B+       | Positions           |           91ms |           90ms |           73ms
Terrier | BM25           | Count               |          357ms |          277ms |          296ms
Terrier | DPH            | Count               |          441ms |          338ms |          369ms
Terrier | DPH + Bo1 QE   | Count (inc. direct) |         1633ms |         1323ms |         1402ms
Terrier | DPH + Prox SD  | Positions           |         1250ms |          950ms |          986ms

##### Extra Notes
###### Terrier
Terrier's indexing as of v4.0 is comparably slow. An inspection of indexing using a profiler found that an [inefficiency had been introduced](http://terrier.org/issues/browse/TR-340). We expect to trivially fix this for the next version 4.1 release.

###### Galago
Galago's SDM calculates expensive ordered and unordered window features, which explains part of the extreme difference. Even Galago's QL, simple unigram model is quite slow in comparison to other engines. We are investigating the bottleneck.

### Retrieval Effectiveness
The systems generated run files to be consumed by the `trec_eval` tool. Each system was evaluated on the top 1000 results for each query, and the table below shows the MAP scores for the systems.

System  | Model                | Index             |Topics 701-750 | Topics 751-800 | Topics 801-850
:-------|:---------------------|-------------------|--------------:|---------------:|--------------:
ATIRE   | BM25                 | Count             |        0.2616 |         0.3106 |         0.2978
ATIRE   | Quantized BM25       | Count + Quantized |        0.2603 |         0.3108 |         0.2974
Galago  | QL                   | Count             |        0.2776 |         0.2937 |         0.2845
Galago  | SDM                  | Positions         |        0.2726 |         0.2911 |         0.3161
Indri   | QL                   | Positions         |        0.2597 |         0.3179 |         0.2830
Indri   | SDM                  | Positions         |        0.2621 |         0.3086 |         0.3165
JASS    | 1B Postings          | Count             |        0.2603 |         0.3109 |         0.2972
JASS    | 2.5M Postings        | Count             |        0.2579 |         0.3053 |         0.2959
Lucene  | BM25                 | Count             |        0.2684 |         0.3347 |         0.3050
Lucene  | BM25                 | Positions         |        0.2684 |         0.3347 |         0.3050
MG4J    | BM25                 | Count             |        0.2640 |         0.3336 |         0.2999
MG4J    | Model B              | Count             |        0.2469 |         0.3207 |         0.3003
MG4J    | Model B+             | Positions         |        0.2322 |         0.3179 |         0.3257
Terrier | BM25                 | Count             |        0.2432 |         0.3039 |         0.2614
Terrier | DPH                  | Count             |        0.2768 |         0.3311 |         0.2899
Terrier | DPH + Bo1 QE         | Count (inc direct)|        0.3037 |         0.3742 |         0.3480
Terrier | DPH + Proximity (SD) | Positions         |        0.2750 |         0.3297 |         0.2897

##### Statistical Analysis

**TODO:** Need to run statistical analyses.
