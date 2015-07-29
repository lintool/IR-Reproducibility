#!/bin/bash

# remove all temporary, intermediate and result folders and files

# 2015 July 22 - James Valenti/Jamie Callan Carnegie Mellon University

# indri 
# DO NOT REMOVE INDEX (unless you really intend to)
# 
#rm -f ./build_index.log.stderr
#rm -f ./build_index.log.stdout
#rm -f ./indri-5.3.tar.gz
#rm -rf ./indri-5.3

# queries
# these are typically removed between query parameter adjustments and benchmarking runs
rm -fr ./queries
rm -fr ./query_results
rm -f  ./results
rm -fr ./scores
