# CSE310: Compiler Sessional

> A complete compiler construction pipeline built incrementally across four assignments — from symbol table management to 8086 assembly code generation.

**Student:** Mohammad Ninad Mahmud Nobo  
**Roll:** 2005080  
**Course:** CSE310 — Compiler Sessional

---

## Overview

This repository implements the core phases of a compiler for a subset of the C programming language:

| Phase | Assignment | Description |
|-------|-----------|-------------|
| **1** | Symbol Table | Hash-based symbol table with scope management |
| **2** | Lexical Analysis | Token recognition using Flex |
| **3** | Syntax & Semantic Analysis | Parsing and type checking using Bison/Yacc |
| **4** | Intermediate Code Generation | 8086 assembly output with peephole optimization |

Each assignment builds on the previous one, forming a full compilation pipeline by Assignment 4.

---

## Prerequisites

- **g++** (C++17 support)
- **Flex** (lexical analyzer generator)
- **Bison / Yacc** (parser generator)
- **Linux / macOS** (bash shell)

```bash
# Ubuntu/Debian
sudo apt install g++ flex bison
```

---

## Assignment 1 — Symbol Table

**Directory:** `Assignment-01_SymbolTable/`

A standalone symbol table implementation using **hash chaining** with support for nested scopes.

### Key Components

| File | Description |
|------|-------------|
| `SymbolTable/2005080_SymbolInfo.cpp` | `SymbolInfo` — stores symbol name, type, data type, and function parameter lists |
| `SymbolTable/2005080_ScopeTable.cpp` | `ScopeTable` — hash table for a single scope with insert, lookup, and delete |
| `SymbolTable/2005080_SymbolTable.cpp` | `SymbolTable` — manages a stack of `ScopeTable`s for nested scope handling |
| `2005080_main.cpp` | Driver program that reads commands from input and performs symbol table operations |

### Supported Commands

| Command | Operation |
|---------|-----------|
| `I name type` | Insert a symbol |
| `L name` | Lookup a symbol |
| `D name` | Delete a symbol |
| `P A` | Print all scope tables |
| `P C` | Print the current scope table |
| `S` | Enter a new scope |
| `E` | Exit the current scope |
| `Q` | Quit |

### How to Run

```bash
cd Assignment-01_SymbolTable
bash run.sh
```

Or manually:

```bash
g++ -o main 2005080_main.cpp -std=c++17
./main
```

- **Input:** `input/input.txt`
- **Output:** `output/2005080_output_01.txt`
- **Expected:** `sample_output/output_01.txt`

---

## Assignment 2 — Lexical Analysis

**Directory:** `Assignment-02_LexicalAnalysis/`

A Flex-based lexical analyzer that tokenizes a C-like language, producing a token stream and a detailed log.

### Features

- Recognizes keywords (`if`, `else`, `for`, `while`, `int`, `float`, `void`, `return`)
- Identifies operators (`ADDOP`, `MULOP`, `RELOP`, `LOGICOP`, `ASSIGNOP`, `INCOP`, `DECOP`, `NOT`)
- Handles integer and floating-point constants (including scientific notation)
- Processes character literals and string literals (single-line and multi-line)
- Supports single-line (`//`) and multi-line (`/* */`) comments
- Detects lexical errors: unfinished strings, unfinished comments, multichar constants, empty char, too many decimal points, ill-formed numbers, invalid suffixes/prefixes, and unrecognized characters
- Integrates with the Symbol Table from Assignment 1

### How to Run

```bash
cd Assignment-02_LexicalAnalysis
bash run.sh
```

Or manually:

```bash
flex 2005080.l
g++ lex.yy.c -o scanner -std=c++17
./scanner input/input1.txt output/token.txt output/log.txt
```

- **Input:** `input/input1.txt` through `input/input4.txt`
- **Output:** Token files (`output/2005080_token_XX.txt`) and log files (`output/2005080_log_XX.txt`)
- **Expected:** `sample_output/token_XX.txt` and `sample_output/log_XX.txt`

---

## Assignment 3 — Syntax & Semantic Analysis

**Directory:** `Assignment-03_Syntax&SemanticAnalysis/`

A Bison/Yacc parser coupled with the Flex scanner to perform syntax analysis and semantic checking, producing a parse tree and error reports.

### Key Components

| File | Description |
|------|-------------|
| `2005080.y` | Bison grammar — defines the CFG rules and semantic actions |
| `2005080.l` | Flex scanner — tokenizer integrated with the parser |
| `2005080_ParseTree.cpp` | Parse tree construction and indented pretty-printing |
| `2005080_HelperFunction.cpp` | Semantic analysis utilities (type checking, redefinition detection, etc.) |
| `SymbolTable/` | Symbol table classes reused from previous assignments |

### Grammar Support

- **Declarations:** variable declarations (with arrays), function declarations & definitions
- **Statements:** expression statements, compound statements, `if`/`if-else`, `for`, `while`, `return`
- **Expressions:** assignment, logical, relational, arithmetic, unary, function calls
- **Error recovery:** Syntax error recovery in parameter lists, declaration lists, and expressions

### Semantic Checks

- Variable/function redeclaration and redefinition detection
- Type checking for expressions and assignments
- Void variable declaration detection
- Function argument count and type mismatch
- Conflicting type detection
- Undeclared variable/function usage

### Output Files

For each input file, three output files are generated:

| Output | Description |
|--------|-------------|
| `*_log_XX.txt` | Detailed parsing log with token discovery, grammar rule reductions, and symbol table dumps |
| `*_error_XX.txt` | Semantic error messages with line numbers |
| `*_parseTree_XX.txt` | Indented parse tree showing the complete derivation |

### How to Run

```bash
cd "Assignment-03_Syntax&SemanticAnalysis"
bash run.sh
```

Or manually:

```bash
yacc --yacc -d --debug 2005080.y -o y.tab.cpp
flex -o 2005080.cpp 2005080.l
g++ -w 2005080.cpp y.tab.cpp -o parser -std=c++17
./parser input/input1.txt output/log.txt output/error.txt output/parseTree.txt
```

- **Input:** `input/input1.txt` through `input/input4.txt`
- **Expected:** `sample_output/outputN_log.txt`, `sample_output/outputN_error.txt`, `sample_output/outputN_parseTree.txt`

---

## Assignment 4 — Intermediate Code Generation

**Directory:** `Assignment-04_IntermediateCodeGeneration/`

The final phase — generates **8086 assembly code** from the parsed and type-checked source, with peephole optimization.

### Key Components

| File | Description |
|------|-------------|
| `2005080.y` | Extended Bison grammar with code generation actions |
| `2005080.l` | Flex scanner |
| `2005080_AssemblyGenerator.h` | Core assembly code emitter — handles stack frames, expressions, control flow, and function calls |
| `CodeGenerator.h` | Peephole optimizer — removes redundant `MOV`, `PUSH`/`POP` pairs, and dead code |
| `2005080_ParseTree.h` | Parse tree with expression value propagation |
| `2005080_HelperFunction.h` | Semantic analysis utilities |
| `2005080_SymbolInfo.h` | Extended symbol info with stack offset tracking |
| `2005080_SymbolTable.h` | Symbol table with offset management |
| `2005080_ScopeTable.h` | Scope table |

### Supported Language Features

- Integer variable declarations (scalars and arrays)
- Arithmetic expressions (`+`, `-`, `*`, `/`, `%`)
- Relational and logical expressions
- Assignment statements
- Control flow: `if`/`if-else`, `for`, `while`
- Increment/decrement operators (`++`, `--`)
- Function definitions and calls with parameters
- `println` for output
- `return` statements

### Code Generation Details

- **Stack-based** local variable management with `BP`-relative addressing
- **Register allocation** using `AX`, `BX`, `CX`, `DX`
- **Short-circuit evaluation** for logical expressions
- **Backpatching** for control flow labels
- **Peephole optimization** pass that eliminates:
  - Redundant `MOV` instructions (`MOV AX, AX`)
  - Consecutive `PUSH`/`POP` pairs on the same register
  - Dead `MOV` sequences

### Output Files

| File | Description |
|------|-------------|
| `code_unoptimized.asm` | Raw generated 8086 assembly |
| `code_optimized.asm` | Assembly after peephole optimization |

### How to Run

```bash
cd Assignment-04_IntermediateCodeGeneration
bash script.sh
```

Or manually:

```bash
yacc --yacc -d -Wcounterexamples 2005080.y -o y.tab.cpp
flex -o 2005080.cpp 2005080.l
g++ -w *.cpp
./a.out input.c
```

- **Input:** `input.c`
- **Output:** `code_unoptimized.asm`, `code_optimized.asm`

---

## Project Structure

```
CSE310-Compiler-Sessional/
├── README.md
│
├── Assignment-01_SymbolTable/
│   ├── 2005080_main.cpp              # Driver program
│   ├── run.sh                        # Build & test script
│   ├── SymbolTable/                   # Core data structures
│   │   ├── 2005080_SymbolInfo.cpp
│   │   ├── 2005080_ScopeTable.cpp
│   │   └── 2005080_SymbolTable.cpp
│   ├── input/                         # Test inputs
│   ├── output/                        # Generated outputs
│   └── sample_output/                 # Expected outputs
│
├── Assignment-02_LexicalAnalysis/
│   ├── 2005080.l                      # Flex specification
│   ├── run.sh                         # Build & test script
│   ├── SymbolTable/                   # Symbol table (reused)
│   ├── input/                         # 4 test inputs
│   ├── output/                        # Token + log outputs
│   └── sample_output/                 # Expected outputs
│
├── Assignment-03_Syntax&SemanticAnalysis/
│   ├── 2005080.y                      # Bison grammar
│   ├── 2005080.l                      # Flex scanner
│   ├── 2005080_ParseTree.cpp          # Parse tree implementation
│   ├── 2005080_HelperFunction.cpp     # Semantic analysis helpers
│   ├── run.sh                         # Build & test script
│   ├── SymbolTable/                   # Symbol table (extended)
│   ├── input/                         # 4 test inputs
│   ├── output/                        # Log + error + parse tree
│   └── sample_output/                 # Expected outputs
│
└── Assignment-04_IntermediateCodeGeneration/
    ├── 2005080.y                      # Extended grammar with codegen
    ├── 2005080.l                      # Flex scanner
    ├── 2005080_AssemblyGenerator.h    # 8086 code emitter
    ├── CodeGenerator.h                # Peephole optimizer
    ├── 2005080_ParseTree.h            # Parse tree
    ├── 2005080_HelperFunction.h       # Semantic helpers
    ├── 2005080_SymbolInfo.h           # Extended symbol info
    ├── 2005080_SymbolTable.h          # Symbol table with offsets
    ├── 2005080_ScopeTable.h           # Scope table
    ├── script.sh                      # Build & run script
    ├── input.c                        # Sample C input
    ├── code_unoptimized.asm           # Raw assembly output
    └── code_optimized.asm             # Optimized assembly output
```

---

## Quick Start — Run All Assignments

```bash
# Assignment 1: Symbol Table
cd Assignment-01_SymbolTable && bash run.sh && cd ..

# Assignment 2: Lexical Analysis
cd Assignment-02_LexicalAnalysis && bash run.sh && cd ..

# Assignment 3: Syntax & Semantic Analysis
cd "Assignment-03_Syntax&SemanticAnalysis" && bash run.sh && cd ..

# Assignment 4: Intermediate Code Generation
cd Assignment-04_IntermediateCodeGeneration && bash script.sh && cd ..
```

---

## Compiler Pipeline

```
┌──────────────┐     ┌──────────────────┐     ┌────────────────────┐     ┌──────────────────┐
│  Source Code  │────▶│  Lexical Analysis │────▶│  Syntax & Semantic │────▶│  Code Generation │
│   (input.c)  │     │   (Flex Scanner)  │     │  Analysis (Bison)  │     │  (8086 Assembly)  │
└──────────────┘     └──────────────────┘     └────────────────────┘     └──────────────────┘
                              │                         │                         │
                              ▼                         ▼                         ▼
                        Token Stream              Parse Tree               code_optimized.asm
                        Symbol Table              Error Report             code_unoptimized.asm
```

---

## License

This project was developed as part of the CSE310 Compiler Sessional course. For academic use only.
