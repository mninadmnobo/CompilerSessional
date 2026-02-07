#ifndef SCOPETABLE_H
#define SCOPETABLE_H

#include "2005080_SymbolInfo.h"
#include <string>
#include <fstream>
using namespace std;

extern std::ofstream outFile;

class ScopeTable {
private:
    SymbolInfo **table;
    ScopeTable *parentScope;
    int bucketSize;
    string uniqueId;

public:
    ScopeTable(int bucketSize) {
        this->bucketSize = bucketSize;
        table = new SymbolInfo*[bucketSize];
        for (int i = 0; i < bucketSize; i++) {
            table[i] = nullptr;
        }
        parentScope = nullptr;
    }

    ~ScopeTable() {
        for (int i = 0; i < bucketSize; i++) {
            delete table[i];
        }
        delete[] table;
    }

    string getUniqueId() { return uniqueId; }
    void setUniqueId(string uniqueId) { this->uniqueId = uniqueId; }

    ScopeTable* getParentScope() { return parentScope; }
    void setParentScope(ScopeTable* parentScope) { this->parentScope = parentScope; }

    int getBucketSize() { return bucketSize; }

    unsigned long long hashFunction(string str) {
        unsigned long long hash = 0;
        for (auto ch : str) {
            int c = ch;
            hash = c + (hash << 6) + (hash << 16) - hash;
        }
        return hash % getBucketSize();
    }

    bool insert(SymbolInfo *symbol) {
        unsigned long long hash = hashFunction(symbol->getName());
        int position = 0;
        
        if (table[hash] == nullptr) {
            table[hash] = symbol;
            position++;
            outFile << "\t" << "Inserted  at position "
                    << "<" << hash + 1 << ", " << position << ">"
                    << " of ScopeTable# " << getUniqueId() << endl;
            return true;
        } else {
            SymbolInfo *temp = table[hash];
            while (temp->getNext() != nullptr) {
                if (temp->getName() == symbol->getName()) {
                    outFile << "\t" << "'" << symbol->getName() << "'"
                            << " already exists in the current ScopeTable# " << getUniqueId() << endl;
                    return false;
                }
                temp = temp->getNext();
                position++;
            }
            if (temp->getName() == symbol->getName()) {
                outFile << "\t" << "'" << symbol->getName() << "'"
                        << " already exists in the current ScopeTable# " << getUniqueId() << endl;
                return false;
            }
            temp->setNext(symbol);
            position += 2;
            outFile << "\t" << "Inserted  at position "
                    << "<" << hash + 1 << ", " << position << ">"
                    << " of ScopeTable# " << getUniqueId() << endl;
            return true;
        }
    }

    SymbolInfo* lookup(string name) {
        int count = 0;
        unsigned long hash = hashFunction(name);
        if (table[hash] == nullptr) {
            return nullptr;
        } else {
            SymbolInfo *temp = table[hash];
            while (temp != nullptr) {
                if (temp->getName() == name) {
                    count++;
                    outFile << "\t" << "'" << name << "'"
                            << " found at position "
                            << "<" << hash + 1 << ", " << count << ">"
                            << " of ScopeTable# " << getUniqueId() << endl;
                    return temp;
                }
                temp = temp->getNext();
                count++;
            }
            return temp;
        }
    }

    bool deleteSymbol(string name) {
        int counter = 0;
        unsigned long hash = hashFunction(name);
        if (table[hash] == nullptr) {
            outFile << "\t" << "Not found in the current ScopeTable# " << getUniqueId() << endl;
            return false;
        } else {
            SymbolInfo *temp = table[hash];
            SymbolInfo *prev = nullptr;
            while (temp != nullptr) {
                if (temp->getName() == name) {
                    if (prev == nullptr) {
                        table[hash] = temp->getNext();
                    } else {
                        prev->setNext(temp->getNext());
                    }
                    temp->setNext(nullptr);
                    delete temp;
                    counter++;
                    outFile << "\t" << "Deleted '" << name << "' from position "
                            << "<" << hash + 1 << ", " << counter << ">"
                            << " of ScopeTable# " << getUniqueId() << endl;
                    return true;
                }
                prev = temp;
                temp = temp->getNext();
                counter++;
            }
            outFile << "\t" << "Not found in the current ScopeTable# " << getUniqueId() << endl;
            return false;
        }
    }

    void print() {
        outFile << "\t" << "ScopeTable# " << getUniqueId() << endl;
        for (int i = 1; i <= getBucketSize(); i++) {
            outFile << "\t" << i;
            SymbolInfo *cur = table[i - 1];
            while (cur != nullptr) {
                outFile << " --> (" << cur->getName() << "," << cur->getType() << ")";
                cur = cur->getNext();
            }
            outFile << endl;
        }
    }
};

#endif // SCOPETABLE_H
