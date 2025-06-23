#include <iostream>
#include <fstream>
#include <string>
#include <typeinfo>
#include "2005107_SymbolTable.h"
#include "2005107_fileIo.h"
using namespace std;

int main()
{
    string line;
    if (!inFile.is_open())
    {
        cerr << "Error opening the file!" << endl;
        return 1;
    }
    getline(inFile, line);
    istringstream iss(line);
    int bucketSize;
    iss >> bucketSize;
    // cout<<"           "<<bucketSize<<"bsize"<<endl;
    SymbolTable *symbolTable = new SymbolTable(bucketSize);
    while (getline(inFile, line))
    {
        outFile <<"Cmd "<<++cmdCount<<": "<< line << endl;
        istringstream iss(line);
        string firstChar;
        iss >> firstChar;
        if (firstChar == "I")
        {

            string symbolName, symbolType;
            iss >> symbolName >> symbolType;
            if (symbolName != "" && symbolType != "")
            {
                SymbolInfo *symbol = new SymbolInfo(symbolName, symbolType);
                symbolTable->insert(symbol);
            }
            else
            {
                outFile<<"\t" << "Wrong number of arugments for the command I" << endl;
            }
        }

        if (firstChar == "L")
        {
            string symbolName, secondname;
            iss >> symbolName >> secondname;
            if (secondname == "")
            {
                if (symbolTable->lookup(symbolName) == nullptr)
                {
                    outFile<<"\t" << "'" << symbolName << "' "
                         << "not found in any of the ScopeTables" << endl;
                }
            }
            else
            {
                outFile<<"\t" << "Wrong number of arugments for the command L" << endl;
            }
        }

        if (firstChar == "P")
        {
            string secondChar;
            iss >> secondChar;
            if (secondChar == "C")
            {
                symbolTable->printCurrent();
            }
            else if (secondChar == "A")
            {
                symbolTable->printAll();
            }
            else
            {
                outFile<<"\t" << "Invalid argument for the command P" << endl;
            }
        }

        if (firstChar == "D")
        {

            string secondChar;
            iss >> secondChar;
            if (secondChar != "")
            {
                symbolTable->remove(secondChar);
            }
            else
            {
                outFile<<"\t" << "Wrong number of arugments for the command D" << endl;
            }
        }
        if (firstChar == "S")
        {
            symbolTable->enterScope();
        }
        if (firstChar == "E")
        {
            symbolTable->exitScope();
        }

        if(firstChar =="Q")
        {
            delete symbolTable;
            break;
        }
    }

    inFile.close();
    outFile.close();
    return 0;
}
