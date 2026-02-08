#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <typeinfo>
#include "SymbolTable/2005080_SymbolTable.cpp"
using namespace std;

// File IO variables
string INPUT_FILE = "input/input.txt";
string OUTPUT_FILE = "output/2005080_output_01.txt";
int cmdCount = 0;
ifstream inFile(INPUT_FILE);
FILE* outFile;

int main()
{
    outFile = fopen(OUTPUT_FILE.c_str(), "w");
    string line;
    if (!inFile.is_open())
    {
        cerr << "Error opening the file!" << endl;
        return 1;
    }
    getline(inFile, line);
    istringstream iss(line);    int bucketSize;
    iss >> bucketSize;
    // cout<<"           "<<bucketSize<<"bsize"<<endl;
    SymbolTable *symbolTable = new SymbolTable(bucketSize, outFile);
    while (getline(inFile, line))
    {
        // Remove trailing carriage return if present (for CRLF line endings)
        if (!line.empty() && line.back() == '\r') {
            line.pop_back();
        }
        fprintf(outFile, "Cmd %d: %s\n", ++cmdCount, line.c_str());
        istringstream iss(line);
        string firstChar;
        iss >> firstChar;
        if (firstChar == "I")
        {

            string symbolName, symbolType;
            iss >> symbolName >> symbolType;
            if (symbolName != "" && symbolType != "")
            {
                SymbolInfo *symbol = new SymbolInfo(symbolName, symbolType);                symbolTable->insert(symbol);
            }            else
            {
                fprintf(outFile, "\tWrong number of arguments for the command I\n");
            }
        }

        if (firstChar == "L")
        {
            string symbolName, secondname;
            iss >> symbolName >> secondname;
            if (secondname == "")
            {                if (symbolTable->lookup(symbolName) == nullptr)
                {
                    fprintf(outFile, "\t'%s' not found in any of the ScopeTables\n", symbolName.c_str());
                }
            }            else
            {
                fprintf(outFile, "\tWrong number of arguments for the command L\n");
            }
        }

        if (firstChar == "P")
        {
            string secondChar;
            iss >> secondChar;            if (secondChar == "C")
            {
                symbolTable->printCurrent(outFile);
            }
            else if (secondChar == "A")
            {
                symbolTable->printAll(outFile);
            }
            else
            {
                fprintf(outFile, "\tInvalid argument for the command P\n");
            }
        }

        if (firstChar == "D")
        {

            string secondChar;
            iss >> secondChar;            if (secondChar != "")
            {
                symbolTable->remove(secondChar);
            }            else
            {
                fprintf(outFile, "\tWrong number of arguments for the command D\n");
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
        }    }    inFile.close();
    fclose(outFile);
    return 0;
}