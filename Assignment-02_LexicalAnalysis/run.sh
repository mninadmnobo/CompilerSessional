#!/bin/bash

# Build the scanner
echo "=== Building Scanner ==="
flex 2005080.l
g++ lex.yy.c -o scanner -std=c++17
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi
echo "Build successful!"
echo ""

# Clean output folder
echo "Cleaning output folder..."
rm -f output/*.txt
echo ""

# Count input files
INPUT_COUNT=$(ls input/input*.txt 2>/dev/null | wc -l)

if [ "$INPUT_COUNT" -eq 0 ]; then
    echo "No input files found in input/ folder!"
    exit 1
fi

# Run on each test case
PASS=0
FAIL=0
TOTAL=0

for input_file in input/input*.txt; do
    # Extract test case number from filename (e.g., input1.txt -> 1)
    num=$(echo "$input_file" | grep -oP '\d+')
    # Zero-pad to 2 digits
    padded=$(printf "%02d" "$num")

    echo "=== Test Case $padded ==="

    # Run scanner with numbered output files
    ./scanner "$input_file" "output/2005080_token_${padded}.txt" "output/2005080_log_${padded}.txt"

    echo "  Output: output/2005080_token_${padded}.txt, output/2005080_log_${padded}.txt"

    # Compare with sample output if exists
    COMPARED=false
    CASE_FAIL=false

    if [ -f "sample_output/token_${padded}.txt" ]; then
        DIFF=$(diff -Z "output/2005080_token_${padded}.txt" "sample_output/token_${padded}.txt")
        if [ -z "$DIFF" ]; then
            echo "  Token output: PASSED ✅"
        else
            echo "  Token output: FAILED ❌"
            echo "$DIFF" | head -20
            CASE_FAIL=true
        fi
        COMPARED=true
    fi

    if [ -f "sample_output/log_${padded}.txt" ]; then
        DIFF=$(diff -Z "output/2005080_log_${padded}.txt" "sample_output/log_${padded}.txt")
        if [ -z "$DIFF" ]; then
            echo "  Log output:   PASSED ✅"
        else
            echo "  Log output:   FAILED ❌"
            echo "$DIFF" | head -20
            CASE_FAIL=true
        fi
        COMPARED=true
    fi

    if [ "$COMPARED" = false ]; then
        echo "  No sample output found for test case $padded (skipping comparison)"
    elif [ "$CASE_FAIL" = true ]; then
        FAIL=$((FAIL + 1))
    else
        PASS=$((PASS + 1))
    fi

    TOTAL=$((TOTAL + 1))
    echo ""
done

# Cleanup generated files
rm -f lex.yy.c scanner

# Summary
echo "=== Summary ==="
echo "Total test cases: $TOTAL"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "Output files are in output/ folder"
