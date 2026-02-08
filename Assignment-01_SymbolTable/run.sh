#!/bin/bash

# Symbol Table - Compilation and Execution Script
# This script compiles and runs the Symbol Table project, then compares with sample output

echo "=== Symbol Table Project ==="
echo ""

# Compile the project
echo "Compiling..."
g++ -o main 2005080_main.cpp -std=c++17

# Check if compilation was successful
if [ $? -ne 0 ]; then
    echo "❌ Compilation failed!"
    exit 1
fi

echo "✅ Compilation successful!"
echo ""

# Clean output folder
echo "Cleaning output folder..."
rm -f output/*.txt
echo ""

# Run the program
echo "Running program..."
echo "-----------------------------------"
./main
echo "-----------------------------------"
echo ""

# Check if execution was successful
if [ $? -eq 0 ]; then
    echo "✅ Execution completed successfully!"
else
    echo "❌ Execution failed!"
    exit 1
fi

echo ""
echo "=== Comparing output with sample ==="
echo ""

PASS=0
FAIL=0

if [ -f "sample_output/output_01.txt" ]; then
    DIFF=$(diff "output/2005080_output_01.txt" "sample_output/output_01.txt")
    if [ -z "$DIFF" ]; then
        echo "✅ Output matches sample_output/output_01.txt perfectly!"
        PASS=1
    else
        echo "❌ Mismatches found:"
        echo ""
        diff -u "output/2005080_output_01.txt" "sample_output/output_01.txt" | head -40
        FAIL=1
    fi
else
    echo "⚠️  sample_output/output_01.txt not found!"
fi

echo ""
echo "=== Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"
