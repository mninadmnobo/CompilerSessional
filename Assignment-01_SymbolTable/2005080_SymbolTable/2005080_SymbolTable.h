#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

#include "2005080_ScopeTable.h"
#include <string>
#include <sstream>
using namespace std;

class SymbolTable {
private:
    ScopeTable* currentScopeTable;
    int bucketSize;
    int currentSIDDeletedScopes;

public:
    SymbolTable(int bucketSize) : bucketSize(bucketSize), currentSIDDeletedScopes(1) {
        currentScopeTable = new ScopeTable(bucketSize);
        currentScopeTable->setUniqueId("1");
        outFile << "\t" << "ScopeTable# 1 created" << endl;
    }

    ~SymbolTable() {
        while (currentScopeTable != nullptr) {
            outFile << "\t" << "ScopeTable# " << currentScopeTable->getUniqueId() << " deleted" << endl;
            ScopeTable *parentScopeTable = currentScopeTable->getParentScope();
            delete currentScopeTable;
            currentScopeTable = parentScopeTable;
        }
    }

    void enterScope() {
        ScopeTable *newScopeTable = new ScopeTable(bucketSize);
        newScopeTable->setParentScope(currentScopeTable);
        string uniqueId = currentScopeTable->getUniqueId();
        currentScopeTable = newScopeTable;
        string newUniqueId = uniqueId + "." + to_string(currentSIDDeletedScopes);
        currentScopeTable->setUniqueId(newUniqueId);
        currentSIDDeletedScopes = 1;
        outFile << "\t" << "ScopeTable# " << newUniqueId << " created" << endl;
    }

    bool insert(SymbolInfo *symbol) {
        return currentScopeTable->insert(symbol);
    }

    SymbolInfo* lookup(string key) {
        ScopeTable *tempScopeTable = currentScopeTable;
        SymbolInfo *symbol = nullptr;
        while (tempScopeTable != nullptr) {
            symbol = tempScopeTable->lookup(key);
            if (symbol != nullptr) {
                return symbol;
            }
            tempScopeTable = tempScopeTable->getParentScope();
        }
        return symbol;
    }

    void printCurrent() {
        currentScopeTable->print();
    }

    void printAll() {
        ScopeTable *tempScopeTable = currentScopeTable;
        while (tempScopeTable != nullptr) {
            tempScopeTable->print();
            tempScopeTable = tempScopeTable->getParentScope();
        }
    }

    void remove(string key) {
        currentScopeTable->deleteSymbol(key);
    }

    bool exitScope() {
        if (currentScopeTable->getParentScope() == nullptr) {
            outFile << "\t" << "ScopeTable# 1 cannot be deleted" << endl;
            return false;
        } else {
            ScopeTable *tempScopeTable = currentScopeTable;
            currentScopeTable = currentScopeTable->getParentScope();
            string id = tempScopeTable->getUniqueId();
            outFile << "\t" << "ScopeTable# " << id << " deleted" << endl;
            
            istringstream iss(id);
            string component;
            int lastNumber = 0;
            while (getline(iss, component, '.')) {
                istringstream(component) >> lastNumber;
            }

            delete tempScopeTable;
            currentSIDDeletedScopes = lastNumber + 1;
            return true;
        }
    }
};

#endif // SYMBOLTABLE_H
