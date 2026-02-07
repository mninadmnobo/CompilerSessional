#include "2005080_SymbolInfo.h"

SymbolInfo::SymbolInfo() {
    name = "";
    type = "";
    next = nullptr;
}

SymbolInfo::SymbolInfo(string name, string type) {
    this->name = name;
    this->type = type;
    next = nullptr;
}

void SymbolInfo::setName(string name) {
    this->name = name;
}

void SymbolInfo::setType(string type) {
    this->type = type;
}

void SymbolInfo::setNext(SymbolInfo* next) {
    this->next = next;
}

string SymbolInfo::getName() {
    return name;
}

string SymbolInfo::getType() {
    return type;
}

SymbolInfo* SymbolInfo::getNext() {
    return next;
}

SymbolInfo::~SymbolInfo() 
{
    if(next!=NULL)
    {

         delete next;
    }
    


}
