#!/bin/bash

# Intermediate Code Generation - Build and Run Script

echo "=== Intermediate Code Generation ==="
echo ""

# Clean stale generated files
rm -f 2005080.cpp y.tab.cpp y.tab.hpp a.out

# Step 1: Generate parser
echo "Step 1: Running yacc..."
yacc --yacc -d -Wcounterexamples 2005080.y -o y.tab.cpp 2>&1
if [ $? -ne 0 ]; then
    echo "❌ yacc failed!"
    exit 1
fi
echo "  y.tab.cpp and y.tab.hpp created"

# Step 2: Generate scanner
echo "Step 2: Running flex..."
flex -o 2005080.cpp 2005080.l
if [ $? -ne 0 ]; then
    echo "❌ flex failed!"
    exit 1
fi
echo "  Scanner created"

# Step 3: Compile
echo "Step 3: Compiling..."
g++ -w 2005080.cpp y.tab.cpp -o a.out -std=c++17
if [ $? -ne 0 ]; then
    echo "❌ Compilation failed!"
    exit 1
fi
echo "✅ Build successful!"
echo ""

# Run the compiler
echo "Running compiler on input.c..."
echo "-----------------------------------"
./a.out input.c
EXIT_CODE=$?
echo "-----------------------------------"
echo ""

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Execution completed successfully!"
else
    echo "❌ Execution failed!"
fi

# Cleanup intermediate files
rm -f 2005080.cpp y.tab.cpp y.tab.hpp a.out
rm -f input_parsetree.txt input_log.txt input_error.txt

echo ""
echo "=== Output ==="
echo "  code_unoptimized.asm"
echo "  code_optimized.asm"
