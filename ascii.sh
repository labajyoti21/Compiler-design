#!/bin/bash

# Function to convert ASCII to decimal
ascii_to_decimal() {
    local ascii="$1"
    printf "%d\n" "'$ascii"
}

# Main script
if [ $# -eq 0 ]; then
    # If no arguments provided, read from standard input
    while IFS= read -r -n1 ascii_char; do
        decimal=$(ascii_to_decimal "$ascii_char")
        echo "$decimal"
    done
elif [ $# -eq 1 ]; then
    # Read from command-line argument
    ascii_char="$1"
    decimal=$(ascii_to_decimal "$ascii_char")
    echo "$decimal"
elif [ $# -gt 1 ]; then
    echo "Usage: $0 [<ASCII_character>]"
    exit 1
fi
