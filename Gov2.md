# .GOV2 Comparisons
What follows is an initial comparison of selected information retrieval systems on the .GOV2 collection using scripts provided by authors/leading contributors of those systems. The systems are listed in alphabetical order.

## Indexing
Two metrics for indexing are reported below: the size of the generated index, and the time taken to generate that index.

System  | Type              |   Size |         Time
:-------|:------------------|-------:|------------:
ATIRE   | Count             |  12 GB |          33m
ATIRE   | Count + Quantized |  12 GB |          51m
Galago  | Count             |  14 GB |       6h 32m
Galago  | Positions         |  45 GB | 7h < t < 17h
MG4J    | Count             | 7.8 GB |       1h 27m
Terrier | Count             | 9.1 GB |       9h 24m

###### ATIRE
+ The quantized index pre-calculates the BM25 scores at indexing time and stores these instead of term frequencies, more about the quantization in ATIRE can be found [here](http://www.cs.otago.ac.nz/homepages/andrew/papers/2013-6.pdf).
  + The quantization is performed single threaded although easily parallelized.
+ Both indexes were stemmed using an s-stripping stemmer.
+ Both indexes were pruned of SGML tags, used for typically unused search time features.
+ Both indexes postings lists are stored impact ordered, with docids being compressed using variable-byte compression after being delta encoded.
+ ATIRE indexes are a single file, the sizes were determined using `du -h` on each file.

###### Terrier
+ Docids are compressed using gamma delta-gaps and the term frequencies using unary.
+ The size was determined by running `du -h` on the `var/index` folder.

## Retrieval
Both retrieval efficiency (by query latency) and effectiveness (MAP@1000) were measured on three query sets: 701-750, 751-800 and 801-850.

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
+ SDM is our implementation of the [Markov-Random-Field model for Term Dependencies (Metzler & Croft 2005)](http://www-dev.ccs.neu.edu/home/yzsun/classes/2014Spring_CS7280/Papers/Probabilistic_Models/A%20Markov%20Random%20Field%20Model%20for%20Term%20Dependencies.pdf).
    + The features used are: unigrams, bigrams, and unordered windows of size 8.
+ Both of these models require parameter tuning for best performance. No stopping was done for these models.

###### MG4J
+ Model B is described [here](http://trec.nist.gov/pubs/trec15/papers/umilano.tera.final.pdf).
+ The BM25 column shows a baseline based on the BM25 score function applied to the results of the title query treated as a bag of words.

###### Terrier
+ **TODO:** Add some description of the Terrier models.

### Retrieval Latency
The table below shows the average search time across queries by query set. The search times were taken from the internal reporting of each systems.

System  | Model          | Topics 701-750 | Topics 751-800 | Topics 801-850
:-------|:---------------|---------------:|---------------:|--------------:
ATIRE   | BM25           |          149ms |          253ms |          220ms
ATIRE   | Quantized BM25 |           74ms |           78ms |           69ms
Galago  | QL             |          771ms |          821ms |          650ms
Galago  | SDM            |         1077ms |         1813ms |         1026ms
MG4J    | BM25           |          344ms |          248ms |          261ms
MG4J    | Model B        |           30ms |           43ms |           30ms
Terrier | *???*          |          484ms |          300ms |          337ms

##### Extra Notes
###### Galago
Galago's SDM calculates expensive ordered and unordered window features, which explains part of the extreme difference. Even Galago's QL, simple unigram model is quite slow in comparison to other engines. We are investigating the bottleneck.

### Retrieval Effectiveness
The systems generated run files to be consumed by the `trec_eval` tool. Each system was evaluated on the top 1000 results for each query, and the table below shows the MAP scores for the systems.

System  | Model          | Topics 701-750 | Topics 751-800 | Topics 801-850
:-------|:---------------|---------------:|---------------:|--------------:
ATIRE   | BM25           |         0.2616 |         0.3106 |         0.2978
ATIRE   | Quantized BM25 |         0.2361 |         0.2952 |         0.2844
Galago  | QL             |         0.2776 |         0.2937 |         0.2845
Galago  | SDM            |         0.2726 |         0.2911 |         0.3161
MG4J    | BM25           |         0.2640 |         0.3336 |         0.2999
MG4J    | Model B        |         0.2469 |         0.3207 |         0.3003
Terrier | *???*          |         0.2429 |         0.3081 |         0.2640

##### Statistical Analysis
**TODO:** Update statistical analyses below:

~~There are negligible differences between these systems for MAP, with Terrier performing better on queries 701-750 and 751-800, and ATIRE better on queries 801-850. These negligible differences hold true for the other metrics reported by the `trec_eval` tool.~~

~~The table below shows the p-value when performing a paired two-tailed t-test between the ATIRE and Terrier systems on the per-query AP scores.~~

Queries  | p-value
---------|-------:
 701-750 |  0.8006
 751-800 |  0.3759
 801-850 |  0.2126
Combined |  0.9590
