#ifndef SCOPETABLE_H
#define SCOPETABLE_H
#include "2005107_fileIo.h"
#include "2005107_SymbolInfo.h"
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
    void print();
};

#endif // SCOPETABLE_H
