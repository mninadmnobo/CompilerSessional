#!/bin/bash

# Syntax & Semantic Analysis - Compilation and Execution Script

echo "=== Syntax & Semantic Analysis ==="
echo ""

# Build
echo "Building..."

# Remove stale generated files to avoid multiple definition errors
rm -f lex.yy.cpp y.tab.cpp y.tab.hpp 2005080.cpp

yacc --yacc -d --debug 2005080.y -o y.tab.cpp 2>&1
echo "  yacc done"
flex -o 2005080.cpp 2005080.l
echo "  flex done"
g++ -w 2005080.cpp y.tab.cpp -o parser -std=c++17
if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi
echo "✅ Build successful!"
echo ""

# Clean output folder
echo "Cleaning output folder..."
rm -f output/*.txt
echo ""

# Run on each test case
PASS=0
FAIL=0
TOTAL=0

for input_file in input/input*.txt; do
    num=$(echo "$input_file" | grep -oP '\d+')
    padded=$(printf "%02d" "$num")

    echo "=== Test Case $padded ==="

    LOG="output/2005080_log_${padded}.txt"
    ERR="output/2005080_error_${padded}.txt"
    TREE="output/2005080_parseTree_${padded}.txt"

    ./parser "$input_file" "$LOG" "$ERR" "$TREE"

    echo "  Output: $LOG, $ERR, $TREE"

    COMPARED=false
    CASE_FAIL=false

    # Compare log
    SAMPLE_LOG="sample_output/output${num}_log.txt"
    if [ -f "$SAMPLE_LOG" ]; then
        DIFF=$(diff -Z "$LOG" "$SAMPLE_LOG")
        if [ -z "$DIFF" ]; then
            echo "  Log output:       PASSED ✅"
        else
            echo "  Log output:       FAILED ❌"
            echo "$DIFF" | head -20
            CASE_FAIL=true
        fi
        COMPARED=true
    fi

    # Compare error
    SAMPLE_ERR="sample_output/output${num}_error.txt"
    if [ -f "$SAMPLE_ERR" ]; then
        DIFF=$(diff -Z "$ERR" "$SAMPLE_ERR")
        if [ -z "$DIFF" ]; then
            echo "  Error output:     PASSED ✅"
        else
            echo "  Error output:     FAILED ❌"
            echo "$DIFF" | head -20
            CASE_FAIL=true
        fi
        COMPARED=true
    fi

    # Compare parse tree (handle typo in sample: "parsreTree" for test 4)
    SAMPLE_TREE="sample_output/output${num}_parseTree.txt"
    if [ ! -f "$SAMPLE_TREE" ]; then
        SAMPLE_TREE="sample_output/output${num}_parsreTree.txt"
    fi
    if [ -f "$SAMPLE_TREE" ]; then
        DIFF=$(diff -Z "$TREE" "$SAMPLE_TREE")
        if [ -z "$DIFF" ]; then
            echo "  ParseTree output: PASSED ✅"
        else
            echo "  ParseTree output: FAILED ❌"
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
rm -f 2005080.cpp lex.yy.cpp y.tab.cpp y.tab.hpp parser

# Summary
echo "=== Summary ==="
echo "Total test cases: $TOTAL"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "Output files are in output/ folder"
