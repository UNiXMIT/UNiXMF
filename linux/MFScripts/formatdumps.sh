#!/bin/bash
DUMPS=0
if [[ -f "casdumpa.rec" ]]; then
    DUMPS=1
    printf "\nFormatting casdumpa...\n"
    casdup$1 -icasdumpa.rec -fcasdumpa.txt -w -d
fi
if [[ -f "casdumpb.rec" ]]; then
    DUMPS=1
    printf "\nFormatting casdumpb...\n"
    casdup$1 -icasdumpb.rec -fcasdumpb.txt -w -d
fi
if [[ -f "casdumpx.rec" ]]; then
    DUMPS=1
    printf "\nFormatting casdumpx...\n"
    casdup$1 -icasdumpx.rec -fcasdumpx.txt -w -d
fi
if [[ -f "casauxta.rec" ]]; then
    DUMPS=1
    printf "\nFormatting casauxta...\n"
    casdup$1 -icasauxta.rec -fcasauxta.txt -w -d
fi
if [[ -f "casauxtb.rec" ]]; then
    DUMPS=1
    printf "\nFormatting casauxtb...\n"
    casdup$1 -icasauxtb.rec -fcasauxtb.txt -w -d
fi
if [[ $DUMPS = 1 ]]; then
    printf "\nFormatting Complete!\n\n"
elif [[ $DUMPS = 0 ]]; then
    printf "\nNo Files Found!\n\n"
fi
