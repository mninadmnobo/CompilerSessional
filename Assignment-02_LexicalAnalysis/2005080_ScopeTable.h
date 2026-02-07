#ifndef SCOPETABLE_H
#define SCOPETABLE_H
#include "2005080_SymbolInfo.h"
#include "2005080_ScopeTable.h"
#include <bits/stdc++.h>
using namespace std;

class ScopeTable
{
private:
    SymbolInfo **table;
    ScopeTable *parentScope;
    int bucketSize;
    string uniqueId;

public:
    ScopeTable(int bucketSize);
    ~ScopeTable();
    std::string getUniqueId();
    void setUniqueId(string uniqueId);

    ScopeTable *getParentScope();
    void setParentScope(ScopeTable *parentScope);

    int getBucketSize();

    unsigned long long hashFunction(string str);

    bool insert(SymbolInfo *symbol);
    SymbolInfo* lookup(string name);
    bool deleteSymbol(string name);
    void print(FILE* file);
};

#endif // SCOPETABLE_H
