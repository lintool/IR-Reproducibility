# .GOV2 Comparisons
What follows is an initial comparison of selected information retrieval systems on the .GOV2 collection using scripts provided by authors/leading contributors of those systems.

The two systems compared are ATIRE and Terrier, with more to follow.

More detailed information about the ATIRE script can be found [here](./tree/master/systems/ATIRE).

## Indexing
Two metrics for indexing are reported below: the size of the generated index, and the time taken to generate that index.

System  | Type      |   Size |         Time
--------|-----------|--------|--------------:
ATIRE   | Count     |  13 GB | 34m
Terrier | Count     | 9.1 GB | 9h 24m
Galago  | Count     | 14 GB  | 6h 32m
Galago  | Positions | 45 GB  | 7h &lt; t &lt; 17h
MG4J    | Count     | 7.8 GB | 1h 27m

The substantial size difference between the systems can be probably be explained by the methods of compression enabled by both systems. The ATIRE indexer for example uses variable-byte compression of the docids (after they have been delta encoded), and term frequencies, while the Terrier uses gamma delta-gaps for the docids and unary for the term frequencies.

The commands run to get these sizes are:
```
du -h terrier/terrier-4.0/var/index/
du -h ATIRE/atire/index.aspt
```

## Retrieval

### Retrieval Models

**ATIRE**

+ **TODO:** Add some description of the ATIRE models

**Terrier**

+ **TODO:** Add some description of the Terrier models

**Galago**

+ QL is our baseline query-likelihood (bag-of-words) model with dirichlet smoothing and default mu parameters.
+ SDM is our implemntation of the Markov-Random-Field model for Term Dependencies (Metzler & Croft 2005)
    + The features used are: unigrams, bigrams, and unordered windows of size 8.
+ Both of these models require parameter tuning for best performance. No stopping was done for these models.

**MG4J**

+ Model B is described [here](http://trec.nist.gov/pubs/trec15/papers/umilano.tera.final.pdf).
+ The BM25 column shows a baseline based on the BM25 score function applied to the results of the title query treated as a bag of words.

### Retrieval Latency

The table below shows the average search time across all the queries by query set. The search times were taken from the internal reporting for each query of each of the systems.

System         |   ATIRE | Terrier | Galago | Galago | MG4J    | MG4J
---------------|--------:|--------:|-------:|-------:|--------:|-------:
*Model*        |      ?? |     ??  |    QL  |   SDM  | Model B |   BM25
Topics 701-750 |   442ms |   484ms | 771ms  | 1077ms |    30ms |  344ms
Topics 751-800 |   435ms |   300ms | 821ms  | 1813ms |    43ms |  248ms
Topics 801-850 |   430ms |   337ms | 650ms  | 1026ms |    30ms |  261ms

The ATIRE system was searched to completion, and while it also supports quantizing the scores at indexing time this option was not enabled for these runs. These choices may be the reasoning for the differences in timings. 

** Galago **
Galago's SDM calculates expensive ordered and unordered window features, which explains part of the extreme difference. Even Galago's QL, simple unigram model is quite slow in comparison to other engines. We are investigating the bottleneck.

### Retrieval Effectiveness

The systems generated run files to be consumed by the `trec_eval` tool. Each system generated the top 1000 results for each query, and the table below shows the MAP scores for the systems.

System         |   ATIRE | Terrier | Galago | Galago | MG4J    | MG4J
---------------|--------:|--------:|-------:|-------:|--------:|-------:
*Model*        |      ?? |     ??  |   QL   |  SDM   | Model B |   BM25
Topics 701-750 |  0.2397 |  0.2429 | 0.2776 | 0.2726 |  0.2469 | 0.2640
Topics 751-800 |  0.2972 |  0.3081 | 0.2937 | 0.2911 |  0.3207 | 0.3336
Topics 801-850 |  0.2791 |  0.2640 | 0.2845 | 0.3161 |  0.3003 | 0.2999

**TODO:** Update statistical analyses below:

There are negligible differences between these systems for MAP, with Terrier performing better on queries 701-750 and 751-800, and ATIRE better on queries 801-850. These negligible differences hold true for the other metrics reported by the `trec_eval` tool.

The table below shows the p-value when performing a paired two-tailed t-test between the ATIRE and Terrier systems on the per-query AP scores.

Queries  | p-value
---------|-------:
 701-750 |  0.8006
 751-800 |  0.3759
 801-850 |  0.2126
Combined |  0.9590
