#!/bin/bash
export MFDIR=/home/products
export COBMODE=64
export TERM=xterm
CURRENT_DIR=$(pwd)

cd "$MFDIR" || exit 1
array=(*/)
echo

if [[ -n "$1" ]]; then
    # Non-interactive mode
    index=$(( $1 - 1 ))
    if (( index < 0 || index >= ${#array[@]} )); then
        echo "Invalid selection: $1"
        echo "Valid selections are 1-${#array[@]}"
        exit 1
    fi
    MF="${array[$index]}"
else
    # Interactive mode
    PS3="Enter the NUMBER of the MFCOBOL installation to use: "
    select MF in "${array[@]}"; do
        [[ -n "$MF" ]] && break
        echo "Invalid selection"
    done
fi

export MFCOBOL="${MFDIR}/${MF%/}"

cd "$CURRENT_DIR" || exit 1
set --
. "$MFCOBOL/bin/cobsetenv"

ENVFILE=/tmp/.mf.env

if [ -e "$ENVFILE" ]; then
    ENVCHK=true
else
    ENVCHK=false
fi

cat > "$ENVFILE" <<EOF
export MFCOBOL="$MFCOBOL"
export COBMODE="$COBMODE"
export TERM="$TERM"
EOF

if [ "$ENVCHK" = false ]; then
    chmod 666 "$ENVFILE"
fi