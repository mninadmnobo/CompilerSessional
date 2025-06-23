#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H
//#include "fileIo.h"

#include "2005107_ScopeTable.h"
#include <iostream>

class SymbolTable {
private:
    ScopeTable* currentScopeTable;
    int bucketSize = 2;
    int currentSIDDeletedScopes = 1;

public:
    SymbolTable(int bucketSize);
    ~SymbolTable();
    void enterScope();
    bool insert(SymbolInfo *symbol);
    SymbolInfo* lookup(string key);
    void printCurrent();
    void remove(string key);
    void printAll();
    bool exitScope();
    };

#endif // SYMBOLTABLE_H
