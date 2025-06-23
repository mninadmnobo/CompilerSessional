#include "2005107_ScopeTable.h"
#include "2005107_SymbolInfo.h"
#include <bits/stdc++.h>
#include "2005107_fileIo.h"
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
        // cout<<'I';
        outFile<<"\t" << "Inserted  at position "
             << "<" << hash + 1 << ", " << position << ">"
             << " of ScopeTable# " << getUniqueId() << endl;
        return true;
    }
    else
    {
        SymbolInfo *temp = table[hash];
        while (temp->getNext() != nullptr)
        {
            if (temp->getName() == symbol->getName())
            {
                outFile<<"\t" << "'" << symbol->getName() << "'"
                     << " already exists in the current ScopeTable# " << getUniqueId() << endl;
                return false;
            }
            temp = temp->getNext();
            position++;
        }
        if (temp->getName() == symbol->getName())
        {
            outFile<<"\t" << "'" << symbol->getName() << "'"
                 << " already exists in the current ScopeTable# " << getUniqueId() << endl;
            return false;
        }
        temp->setNext(symbol);
        position++;
        position++;
        outFile<<"\t" << "Inserted  at position "
             << "<" << hash + 1 << ", " << position << ">"
             << " of ScopeTable# " << getUniqueId() << endl;
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
                outFile<<"\t" << "'" << name << "'"
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

bool ScopeTable::deleteSymbol(string name)
{
    int counter = 0;
    unsigned long hash = hashFunction(name);
    if (table[hash] == nullptr)
    {
        outFile<<"\t" << "Not found in the current ScopeTable# " << getUniqueId() << endl;
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
                    outFile<<"\t" << "Deleted"
                         << " '"
                         << name
                         << "' "
                            "from position "
                         << "<" << hash + 1 << ", " << counter << ">"
                         << " of ScopeTable# " << getUniqueId() << endl;
                    return true;
                }
                else
                {
                    prev->setNext(temp->getNext());
                    delete temp;
                    counter++;
                    outFile<<"\t" << "Deleted"
                         << " '"
                         << name
                         << "' "
                            "from position "
                         << "<" << hash + 1 << ", " << counter << ">"
                         << " of ScopeTable# " << getUniqueId() << endl;

                    return true;
                }
            }
            prev = temp;
            temp = temp->getNext();
        }
        outFile<<"\t" << "Not found in the current ScopeTable# " << getUniqueId() << endl;
        return false;
    }
}

void ScopeTable::print()
{

    outFile<<"\t" << "ScopeTable# " << getUniqueId() << endl;
    for (int i = 1; i <= getBucketSize(); i++)
    {
        outFile <<"\t"<< i;
        SymbolInfo *cur = table[i - 1];
        while (cur != nullptr)
        {
            outFile << " --> ";
            outFile << "(" << cur->getName() << "," << cur->getType() << ")";
            cur = cur->getNext();
        }
        outFile << endl;
    }
}
