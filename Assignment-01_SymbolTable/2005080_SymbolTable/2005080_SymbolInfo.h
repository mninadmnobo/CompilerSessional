#ifndef SYMBOLINFO_H
#define SYMBOLINFO_H

#include <string>
using namespace std;

class SymbolInfo {
private:
    string name;
    string type;
    SymbolInfo* next;

public:
    SymbolInfo() : name(""), type(""), next(nullptr) {}
    
    SymbolInfo(string name, string type) : name(name), type(type), next(nullptr) {}

    void setName(string name) { this->name = name; }
    void setType(string type) { this->type = type; }
    void setNext(SymbolInfo* next) { this->next = next; }

    string getName() { return name; }
    string getType() { return type; }
    SymbolInfo* getNext() { return next; }

    ~SymbolInfo() {
        if (next != nullptr) {
            delete next;
        }
    }
};

#endif // SYMBOLINFO_H
