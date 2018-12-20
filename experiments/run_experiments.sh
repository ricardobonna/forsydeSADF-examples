#!/bin/bash

BINARY=forsyde-sadf-exe
EXP_FILE=experiments.dat

bss="4 8 16"
samps=$(seq 500 500 4000)
fss="16 32 128 512 1024 2048"

echo "" > $EXP_FILE
for bs in $bss; do
    for fs in $fss; do
	for nSamp in $samps; do
	    echo "Running for fsx=$fs fsy=$fs bs=$bs nsamp=$nSamp..."
	    $BINARY $fs $fs $bs $nSamp >> $EXP_FILE
	done
    done
done
