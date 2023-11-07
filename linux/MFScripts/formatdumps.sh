#!/bin/bash
if [[ -f "casdumpa.rec" ]]; then
    printf "\nFormatting casdumpa...\n"
    casdup$1 -icasdumpa.rec -fcasdumpa.txt -w -d
fi
if [[ -f "casdumpb.rec" ]]; then
    printf "\nFormatting casdumpb...\n"
    casdup$1 -icasdumpb.rec -fcasdumpb.txt -w -d
fi
if [[ -f "casdumpx.rec" ]]; then
    printf "\nFormatting casdumpx...\n"
    casdup$1 -icasdumpx.rec -fcasdumpx.txt -w -d
fi
if [[ -f "casauxta.rec" ]]; then
    printf "\nFormatting casauxta...\n"
    casdup$1 -icasauxta.rec -fcasauxta.txt -w -d
fi
if [[ -f "casauxtb.rec" ]]; then
    printf "\nFormatting casauxtb...\n"
    casdup$1 -icasauxtb.rec -fcasauxtb.txt -w -d
fi
printf "\nFormatting Complete!\n"