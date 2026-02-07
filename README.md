# CSE310: Compiler Sessional - Project Overview

**Name:** Mohammad Ninad Mahmud Nobo  
**Roll:** 2005080

This repository contains multiple projects and assignments for a Compiler Sessional course, organized by assignment:

## Directory Structure and How to Run

- **Assignment-01_SymbolTable/**
  - Standalone C++ symbol table implementation.
  - `2005080_SymbolTable/`: Reusable header-only SymbolInfo, ScopeTable, SymbolTable classes.
  - **How to run:**  
    1. Go to `Assignment-01_SymbolTable/`.
    2. Compile with `g++ 2005080_main.cpp -o symbol_table`.
    3. Run with `./symbol_table`.

- **Assignment-02_LexicalAnalysis/**
  - Flex-based lexical analyzer implementation.
  - **How to run:**  
    1. Navigate to `Assignment-02_LexicalAnalysis/`.
    2. Use Flex to generate a scanner: `flex 2005080.l`.
    3. Compile with `g++ lex.yy.c -o scanner`.
    4. Run with `./scanner < input.txt`.

- **Assignment-03_Syntax&SemanticAnalysis/**
  - Bison/Yacc grammar files for syntax and semantic analysis.
  - **How to run:**  
    1. Enter `Assignment-03_Syntax&SemanticAnalysis/`.
    2. Use Flex and Bison to generate code:  
       `bison -d 2005080.y`  
       `flex 2005080.l`
    3. Compile: `g++ 2005080.tab.c lex.yy.c -o parser`
    4. Run: `./parser < input.txt > output.txt`

- **Assignment-04_IntermediateCodeGeneration/**
  - Full compiler pipeline: lexical analysis, syntax analysis, symbol table, parse tree, and assembly code generation.
  - **How to run:**  
    1. Enter `Assignment-04_IntermediateCodeGeneration/`.
    2. Run `./script.sh` to build and execute the compiler pipeline.

---
