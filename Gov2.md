# .GOV2 Comparisons
What follows is an initial comparison of selected information retrieval systems on the .GOV2 collection using scripts provided by authors/leading contributors of those systems.

The two systems compared are ATIRE and Terrier, with more to follow.

More detailed information about the ATIRE script can be found [here](./tree/master/systems/ATIRE).

## Indexing
Two metrics for indexing are reported below: the size of the generated index, and the time taken to generate that index.

### Index Size
The table below reports the size of the generated index.

System  |  Size
--------|-----:
ATIRE   |  13GB
Terrier | 9.1GB
Galago  | 45 GB

The substantial size difference between the systems can be probably be explained by the methods of compression enabled by both systems. The ATIRE indexer for example uses variable-byte compression of the docids (after they have been delta encoded), and term frequencies, while the Terrier uses gamma delta-gaps for the docids and unary for the term frequencies.

The substantial size difference demonstrated by Galago is most likely explained by the fact that Galago uses variable-byte compression like ATIRE, except it also by default stores positions in the index, so that phrases might be calculated, and it doesn't do any vocabulary pruning at index time.

The commands run to get these sizes are:
```
du -h terrier/terrier-4.0/var/index/
du -h ATIRE/atire/index.aspt
```

### Indexing Time
The time to index the collection is shown in the table below. Both sets of timings were taken from the internal reporting of the systems.

System  |          Time
--------|-------------:
ATIRE   |    34m 34.17s
Terrier | 9h 24m 44.35s
Galago  | 7h < t < 17h

## Searching
Two metrics for searching are reported below: the average time to search, and the Mean Average Precision (MAP) of the results.

### Search Time
The table below shows the average search time across all the queries by query set. The search times were taken from the internal reporting for each query of each of the systems.

System  | Queries | Average Time
--------|---------|------------:
ATIRE   | 701-750 |        442ms
        | 751-800 |        435ms
        | 801-850 |        430ms
Terrier | 701-750 |        484ms
        | 751-800 |        300ms
        | 801-850 |        337ms
Galago  | 701-750 |       1077ms
        | 751-800 |       1813ms
        | 801-850 |       1026ms


The ATIRE system was searched to completion, and while it also supports quantizing the scores at indexing time this option was not enabled for these runs. These choices may be the reasoning for the differences in timings. Galago calculates expensive ordered and unordered window features, which explains the extreme difference.

### Search Effectiveness
The systems generated run files to be consumed by the `trec_eval` tool. Each system generated the top 1000 results for each query, and the table below shows the MAP scores for the systems.

System  | Queries |    MAP
--------|---------|------:
ATIRE   | 701-750 | 0.2397
        | 751-800 | 0.2972
        | 801-850 | 0.2791
Terrier | 701-750 | 0.2429
        | 751-800 | 0.3081
        | 801-850 | 0.2640
Galago  | 701-750 | 0.2726
        | 751-800 | 0.2911
        | 801-850 | 0.3161

There are negligible differences between these systems for MAP, with Terrier performing better on queries 701-750 and 751-800, and ATIRE better on queries 801-850. These negligible differences hold true for the other metrics reported by the `trec_eval` tool.

The table below shows the p-value when performing a paired two-tailed t-test between the ATIRE and Terrier systems on the per-query AP scores.

Queries  | p-value
---------|-------:
 701-750 |  0.8006
 751-800 |  0.3759
 801-850 |  0.2126
Combined |  0.9590
