#include "2005080_SymbolTable.h"
#include "2005080_ScopeTable.h"

SymbolTable::SymbolTable(int bucketSize)
{
    this->bucketSize = bucketSize;
    // cout<<"inside symbol table constructor "<<bucketSize<<endl;
    currentScopeTable = new ScopeTable(bucketSize);
    currentScopeTable->setUniqueId("1");
}

SymbolTable::~SymbolTable()
{
    while (currentScopeTable != nullptr)
    {
        ScopeTable *parentScopeTable = currentScopeTable->getParentScope();
        delete currentScopeTable;
        currentScopeTable = parentScopeTable;
    }
}

void SymbolTable::enterScope()
{
    ScopeTable *newScopeTable = new ScopeTable(bucketSize);
    newScopeTable->setParentScope(currentScopeTable);
    string uniqueId = currentScopeTable->getUniqueId();
    currentScopeTable = newScopeTable;
    string newUniqueId = uniqueId + "." + to_string(currentSIDDeletedScopes);
    currentScopeTable->setUniqueId(newUniqueId);
    currentSIDDeletedScopes = 1;
}

bool SymbolTable::insert(SymbolInfo *symbol)
{
    // cout<<"inside insert";
    return currentScopeTable->insert(symbol);
}

SymbolInfo *SymbolTable::lookup(string key)
{
    ScopeTable *tempScopeTable = currentScopeTable;
    SymbolInfo *symbol = nullptr;
    while (tempScopeTable != nullptr)
    {
        symbol = tempScopeTable->lookup(key);
        if (symbol != nullptr)
        {
            return symbol;
        }
        tempScopeTable = tempScopeTable->getParentScope();
    }
    return symbol;
}

void SymbolTable::printCurrent(FILE *file)
{
    currentScopeTable->print(file);
}

void SymbolTable::printAll(FILE *file)
{
    ScopeTable *tempScopeTable = currentScopeTable;
    while (tempScopeTable != nullptr)
    {
        tempScopeTable->print(file);
        tempScopeTable = tempScopeTable->getParentScope();
    }
}

void SymbolTable::remove(string key)
{
    currentScopeTable->deleteSymbol(key);
}

bool SymbolTable::exitScope()
{
    if (currentScopeTable->getParentScope() == nullptr)
    {
    
        return false;
    }
    else
    {
        ScopeTable *tempScopeTable = currentScopeTable;
        currentScopeTable = currentScopeTable->getParentScope();
        string id = tempScopeTable->getUniqueId();        
        istringstream iss(id);
        string component;
        int lastNumber = 0;
        while (getline(iss, component, '.'))
        {
            int number;
            istringstream(component) >> number;
            lastNumber = number;
        }

        delete tempScopeTable;
        currentSIDDeletedScopes=lastNumber+1;
        return true;
    }
}
