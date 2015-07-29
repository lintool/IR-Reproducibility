#!/bin/bash

ATIRE_DIR="../ATIRE/atire"

if [[ ! -d ${ATIRE_DIR} ]]; then
	echo "ATIRE is a prerequisite for JASS"
	exit
fi

if [[ ! -d JASS ]]; then
	git clone https://github.com/lintool/JASS.git
	git checkout -q b27b319
fi

cd JASS
make ATIRE_DIR=../${ATIRE_DIR}
make -C trec2query ATIRE_DIR=../../${ATIRE_DIR}
