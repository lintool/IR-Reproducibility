Scripts
=======

For each collection, there is an -index.sh and an -index-pos.sh script
that will build a non-positional index and a positional index, respectively.
The scripts will print on standard output the construction time. All
scripts use parallel instances and log in a number of *.err files what
is happening in each parallel instance.

For each collection, there is an -eval.sh script that uses a non-positional
index and Model B, an -eval-pos.sh script that uses a positional index and Model B+,
and finally a -bm25.sh that performs a baseline BM25 run. Each script saves
in eval.$queries.txt the results of evaluation and in time.$queries.txt the
overall query time in milliseconds.

Size
====

A non-positional index is formed by the .properties file, the .titles
file, the .pointers[offsets] files, the .counts[offsets] files, the .sizes
file and the .termmap file. A positional index in addition uses the
.positions[offsets] files.

Metadata
========

All metadata is contained in the .properties file (which is a standard,
self-descripting Java property file).
