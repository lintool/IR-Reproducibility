#!/bin/bash

if [[ ! -d "atire" ]]; then
	hg clone http://www.atire.org/hg/atire -r f3102a7a5848
fi

cd atire

make clean all
