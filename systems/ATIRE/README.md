ATIRE
=====

The ATIRE makefile has a set of options that have been already preselected to provide good performance for indexing.

The script `dotgov2.sh` provides a script that will clone the required repositories, build the system, index and search all the query sets.

The indexing program will print progress every million documents that are indexed. It also precalculates and quantises the index using a variant of BM25. The indexing stats are `tee`'d to the file `indexing.txt`.

For search it performs two sets of searches, top-20 and to completion, for each query set generating runs named `atire.<query set>.<completion or topk>.txt`, with stats for those searches in `<query set>.<completion or topk>.search_stats.txt`.

The generated run files can then be evaluated using traditional run evaluation tools.
