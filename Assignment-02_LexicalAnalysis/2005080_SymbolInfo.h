#ifndef SYMBOLINFO_H
#define SYMBOLINFO_H

#include <bits/stdc++.h>
using namespace std;

class SymbolInfo {
private:
    string name;
    string type;
    SymbolInfo* next;

public:
    SymbolInfo();
    SymbolInfo(string name, string type);

    void setName(string name);
    void setType(string type);
    void setNext(SymbolInfo* next);

    string getName();
    string getType();
    SymbolInfo* getNext();

    ~SymbolInfo();
};

#endif
