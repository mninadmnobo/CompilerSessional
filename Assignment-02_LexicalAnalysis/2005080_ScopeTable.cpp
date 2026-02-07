#include "2005080_ScopeTable.h"
#include "2005080_SymbolInfo.h"
#include <bits/stdc++.h>
using namespace std;

ScopeTable::ScopeTable(int bucketSize)
{
    this->bucketSize = bucketSize;
    table = new SymbolInfo *[bucketSize];
    for (int i = 0; i < bucketSize; i++)
    {
        table[i] = nullptr;
    }
    parentScope = nullptr;
}

ScopeTable::~ScopeTable()
{
    for (int i = 0; i < bucketSize; i++)
    {
        delete table[i];
    }
    delete[] table;
}

std::string ScopeTable::getUniqueId()
{
    return uniqueId;
}

void ScopeTable::setUniqueId(string uniqueId)
{
    this->uniqueId = uniqueId;
}

ScopeTable *ScopeTable::getParentScope()
{
    return parentScope;
}

void ScopeTable::setParentScope(ScopeTable *parentScope)
{
    this->parentScope = parentScope;
}

int ScopeTable::getBucketSize()
{
    return bucketSize;
}

unsigned long long ScopeTable::hashFunction(string str)
{
    // cout<<"inside_scopetablecpp_hashfunction "<<str<<endl;
    // cout<<getBucketSize()<<endl;

    unsigned long long hash = 0;
    for (auto ch : str)
    {
        int c = ch;
        hash = c + (hash << 6) + (hash << 16) - hash;
    }
    hash = hash % getBucketSize();

    // cout<<getBucketSize()<<endl;
    // cout<<hash<<endl;
    return hash;
}

bool ScopeTable::insert(SymbolInfo *symbol)
{
    // cout<<"inside_scopetablecpp_insert"<<symbol->getName()<<endl;
    unsigned long long hash = hashFunction(symbol->getName());
    int position = 0;
    // cout<<hash<<endl;
    if (table[hash] == nullptr)
    {
        table[hash] = symbol;
        position++;
        return true;
    }
    else
    {
        SymbolInfo *temp = table[hash];
        while (temp->getNext() != nullptr)
        {
            if (temp->getName() == symbol->getName())
            {
                return false;
            }
            temp = temp->getNext();
            position++;
        }
        if (temp->getName() == symbol->getName())
        {
            return false;
        }
        temp->setNext(symbol);
        position++;
        position++;
        return true;
    }
}

SymbolInfo *ScopeTable::lookup(string name)
{
    int count = 0;
    unsigned long hash = hashFunction(name);
    if (table[hash] == nullptr)
    {
        return nullptr;
    }
    else
    {
        SymbolInfo *temp = table[hash];
        while (temp != nullptr)
        {
            if (temp->getName() == name)
            {
                count++;
                return temp;
            }
            temp = temp->getNext();
            count++;
        }
        return temp;
    }
}

bool ScopeTable::deleteSymbol(string name)
{
    int counter = 0;
    unsigned long hash = hashFunction(name);
    if (table[hash] == nullptr)
    {
        return false;
    }
    else
    {
        SymbolInfo *temp = table[hash];
        SymbolInfo *prev = nullptr;
        while (temp != nullptr)
        {
            if (temp->getName() == name)
            {
                if (prev == nullptr)
                {
                    table[hash] = temp->getNext();
                    delete temp;
                    counter++;
                    return true;
                }
                else
                {
                    prev->setNext(temp->getNext());
                    delete temp;
                    counter++;
                    return true;
                }
            }
            prev = temp;
            temp = temp->getNext();
        }
        return false;
    }
}

void ScopeTable::print(FILE* outFile)
{

    fprintf(outFile, "\tScopeTable# %s\n", getUniqueId().c_str());

    for (int i = 1; i <= getBucketSize(); i++)
    {
        fprintf(outFile, "\t%d", i);
        SymbolInfo* cur = table[i - 1];
        while (cur != nullptr)
        {
            fprintf(outFile, " --> (%s,%s)", cur->getName().c_str(), cur->getType().c_str());
            cur = cur->getNext();
        }
        fprintf(outFile, "\n");
    }
}
