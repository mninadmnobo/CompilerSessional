# CSE310: Compiler Sessional - Project Overview

This repository contains multiple projects and assignments for a Compiler Sessional course, organized by topic:

## Directory Structure and How to Run

- **Intermediate Code Generation (ICG)/**
  - Implements a full compiler pipeline: lexical analysis (Flex), syntax analysis (Bison/Yacc), symbol table, parse tree, and assembly code generation.
  - Main code is in `2005107_ICG/`:
    - `.l` and `.y` files: Flex and Bison/Yacc source for scanner and parser.
    - `*.h`: C++ headers for symbol table, parse tree, code generation, and helpers.
    - `input.c`: Sample C-like input program.
    - `script.sh`: Shell script to build and run the compiler.
    - `code_optimized.asm`, `code_unoptimized.asm`: Generated assembly outputs.
  - `test/`: Test files and print library.
  - **How to run:**  
    1. Enter `Intermediate Code Generation (ICG)/2005107_ICG/`.
    2. Run `./script.sh` to build and execute the compiler pipeline.  
       Output assembly files will be generated in the same directory.

- **Lexical Analysis/**
  - Contains lecture notes, sample Flex code, and test cases for lexical analysis.
  - `Sample code/`: Example Flex programs and scripts.
  - `sample i-o/`: Sample input/output for testing.
  - `Solution/`: Example solutions for lexical analysis assignments.
  - **How to run:**  
    1. Navigate to `Lexical Analysis/Sample code/`.
    2. Use Flex to generate a scanner, e.g., `flex scanner.l`.
    3. Compile with `g++ lex.yy.c -o scanner`.
    4. Run with `./scanner < input.txt`.

- **Symbol Table/**
  - Standalone C++ symbol table implementation.
  - `2005107 Symbol Table/`: Source code for symbol table, scope table, and file I/O.
  - `input output/`: Test input and output files.
  - **How to run:**  
    1. Go to `Symbol Table/2005107 Symbol Table/`.
    2. Compile with `g++ 2005107_main.cpp 2005107_ScopeTable.cpp 2005107_SymbolInfo.cpp 2005107_SymbolTable.cpp 2005107_fileIo.cpp -o symbol_table`.
    3. Run with `./symbol_table < ../input output/input.txt > ../input output/output.txt`.

- **Syntax and Semantic Analysis/**
  - Bison/Yacc grammar files, sample code, and assignment specs for syntax and semantic analysis.
  - `2005107_Solution/`: Main solution files.
  - `demo code/`, `example skeleton/`: Example grammars and scanners.
  - `sample-io/`: Sample input/output for parser and error recovery.
  - **How to run:**  
    1. Enter `Syntax and Semantic Analysis/2005107_Solution/`.
    2. Use Flex and Bison to generate code:  
       `bison -d 2005107.y`  
       `flex 2005107.l`
    3. Compile:  
       `g++ 2005107.tab.c lex.yy.c -o parser`
    4. Run:  
       `./parser < input.txt > output.txt`

---
