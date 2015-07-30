#!/bin/bash

./gensubsetspos.rb  | awk "BEGIN {i = $1 } { print \"\$mode trec \" i \" mg4jAuto\"; print; i = i + 1; }"
