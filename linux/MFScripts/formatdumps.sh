#!/bin/bash
# Usage: formatdumps.sh [casdup suffix, e.g. 64]
CASDUP="casdup${1}"

if ! command -v "$CASDUP" > /dev/null; then
    printf "\n%s not found in PATH (is the MF environment set?)\n\n" "$CASDUP" >&2
    exit 1
fi

DUMPS=0
for name in casdumpa casdumpb casdumpx casauxta casauxtb; do
    [[ -f "$name.rec" ]] || continue
    DUMPS=1
    printf "\nFormatting %s...\n" "$name"
    "$CASDUP" -i"$name.rec" -f"$name.txt" -w -d
done

if [[ $DUMPS -eq 1 ]]; then
    printf "\nFormatting Complete!\n\n"
else
    printf "\nNo Files Found!\n\n"
fi
