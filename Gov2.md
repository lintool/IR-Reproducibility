# .GOV2 Comparisons
What follows is an initial comparison of selected information retrieval systems on the .GOV2 collection using scripts provided by authors/leading contributors of those systems. The systems are listed in alphabetical order.

## Indexing
Two metrics for indexing are reported below: the size of the generated index, and the time taken to generate that index.

System  | Type              |   Size |         Time | Terms | Postings | Tokens |
:-------|:------------------|-------:|-------------:|------:|---------:|--------:
ATIRE   | Count             | 12 GB  |          33m |       |          |        |
ATIRE   | Count + Quantized | 12 GB  |          51m |       |          |        |
Galago  | Count             | 14 GB  |       6h 32m |       |          |        |
Galago  | Positions         | 45 GB  | 22h 58m      |       |          |        |
Indri   | Positions         | 86 GB  |       7h 46m |       |          |        |
Lucene  | Count             | 11 GB  |       1h 24m |       |          |        |
Lucene  | Positions         | 38 GB  |       1h 35m |       |          |        |
MG4J    | Count             | 7.3 GB |       1h 27m | 34.9M |     5.5G |        |
MG4J    | Positions         | 35 GB  |       2h 20m | 34.9M |     5.5G |  23.1G |
Terrier | Count             | 9.1 GB |       9h 24m | 15.3M |     4.6G |  16.2G |
Terrier | Count (inc direct)| 17GB   |      17h 05m | 15.3M |     4.6G |  16.2G |
Terrier | Positions         | 34 GB  |       9h 45m | 15.3M |     4.6G |  16.2G |

###### ATIRE
+ The quantized index pre-calculates the BM25 scores at indexing time and stores these instead of term frequencies, more about the quantization in ATIRE can be found in [Crane et al. (2013)](http://dl.acm.org/citation.cfm?id=2507860).
  + The quantization is performed single threaded although easily parallelized.
+ Both indexes were stemmed using an s-stripping stemmer.
+ Both indexes were pruned of SGML tags, used for typically unused search time features.
+ Both indexes postings lists are stored impact ordered, with docids being compressed using variable-byte compression after being delta encoded.
+ ATIRE indexes are a single file, the sizes were determined using `du -h` on each file.

###### Indri
+ The index contains an inverted index and DocumentTerm vectors (a forward index).
+ Stopwords were removed and terms were stemmed with the Krovetz stemmer.

###### Terrier
+ Docids are compressed using gamma delta-gaps and the term frequencies using unary.
+ The size was determined by running `du -h` on the `var/index` folder.
+ Positions are compressed using gamma delta-gaps.
+ All indexes are built using the singlepass indexer, except the index that includes a direct file, for which we used the slower traditional indexer.
+ * denotes that the index also has field frequencies within the index, namely the TITLE and body.


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
The table below shows the average search time across queries by query set. The search times were taken from the internal reporting of each systems.

System  | Model          | Index             | Topics 701-750 | Topics 751-800 | Topics 801-850
:-------|:---------------|-------------------|---------------:|---------------:|--------------:
ATIRE   | BM25           | Count             |          149ms |          253ms |          220ms
ATIRE   | Quantized BM25 | Count + Quantized |           74ms |           78ms |           69ms
Galago  | QL             | Count             |          771ms |          821ms |          650ms
Galago  | SDM            | Positions         |         1077ms |         1813ms |         1026ms
Indri   | QL             | Positions         |          192ms |          274ms |          197ms
Indri   | SDM            | Positions         |         2268ms |         2048ms |         1305ms
Lucene  | BM25           | Count             |          142ms |          107ms |          120ms
Lucene  | BM25           | Positions         |          173ms |          132ms |          160ms
MG4J    | BM25           | Count             |          344ms |          248ms |          261ms
MG4J    | Model B        | Count             |           30ms |           43ms |           30ms
MG4J    | Model B+       | Positions         |           90ms |           89ms |           73ms
Terrier | DPH            | Count             |          484ms |          300ms |          337ms
Terrier | DPH + Bo1 QE   | Count (inc. direct) |       1636ms |         1326ms |         1402ms
Terrier | DPH + Prox SD  | Positions         |         1579ms |         1373ms |         1413ms

##### Extra Notes
###### Terrier
Terrier's indexing as of v4.0 is comparably slow. An inspection of indexing using a profiler found that an [inefficiency had been introduced](http://terrier.org/issues/browse/TR-340). We expect to trivially fix this for the next version 4.1 release.

###### Galago
Galago's SDM calculates expensive ordered and unordered window features, which explains part of the extreme difference. Even Galago's QL, simple unigram model is quite slow in comparison to other engines. We are investigating the bottleneck.

### Retrieval Effectiveness
The systems generated run files to be consumed by the `trec_eval` tool. Each system was evaluated on the top 1000 results for each query, and the table below shows the MAP scores for the systems.

System  | Model          | Index             |Topics 701-750 | Topics 751-800 | Topics 801-850
:-------|:---------------|-------------------|--------------:|---------------:|--------------:
ATIRE   | BM25           | Count             |        0.2616 |         0.3106 |         0.2978
ATIRE   | Quantized BM25 | Count + Quantized |        0.2361 |         0.2952 |         0.2844
Galago  | QL             | Count             |        0.2776 |         0.2937 |         0.2845
Galago  | SDM            | Positions         |        0.2726 |         0.2911 |         0.3161
Indri   | QL             | Positions         |        0.2597 |         0.3179 |         0.2830
Indri   | SDM            | Positions         |        0.2621 |         0.3086 |         0.3165
Lucene  | BM25           | Count             |        0.2684 |         0.3347 |         0.3050
Lucene  | BM25           | Positions         |        0.2684 |         0.3347 |         0.3050
MG4J    | BM25           | Count             |        0.2640 |         0.3336 |         0.2999
MG4J    | Model B        | Count             |        0.2469 |         0.3207 |         0.3003
MG4J    | Model B+       | Positions         |        0.2322 |         0.3179 |         0.3257
Terrier | BM25           | Count             |        0.2485 |         0.3153 |         0.2726
Terrier | DPH            | Count             |        0.2768 |         0.3311 |         0.2899
Terrier | DPH + Bo1 QE   | Count (inc direct)|        0.3037 |         0.3742 |         0.3480
Terrier | DPH + Proximity (SD)| Positions    |        0.2792 |         0.3261 |         0.2906

##### Statistical Analysis

**TODO:** Need to run statistical analyses.
