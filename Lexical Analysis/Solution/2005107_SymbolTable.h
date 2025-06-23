#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H
#include "2005107_SymbolInfo.h"
#include "2005107_ScopeTable.h"
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
    void printCurrent(FILE *file);
    void remove(string key);
    void printAll(FILE *file);
    bool exitScope();
    };

#endif // SYMBOLTABLE_H
