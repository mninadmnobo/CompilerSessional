#ifndef PARSETREE_CPP
#define PARSETREE_CPP

#include <bits/stdc++.h>
using namespace std;

typedef struct expression
{
    string id;
    float value;
    string dataType;
    bool isZero;
} expression;

class ParseTree
{
private:
    ParseTree *head;
    vector<ParseTree *> *children;
    bool isTerminal;
    string rule;
    int lineBegin;
    int lineEnd;
    string dataType;
    expression exp;
    vector<expression> *expressionList;

public:
    ParseTree(bool isTerminal, string rule, int lineBegin, int lineEnd)
    {
        this->isTerminal = isTerminal;
        this->rule = rule;
        this->lineBegin = lineBegin;
        this->lineEnd = lineEnd;
        this->children = new vector<ParseTree *>();
        dataType = "";
        expressionList = new vector<expression>();
    }

    ParseTree()
    {
        this->children = new vector<ParseTree *>();
        expressionList = new vector<expression>();
    }

    ~ParseTree()
    {
        while (!children->empty())
        {
            delete children->back();
            children->pop_back();
        }
        delete children;
        delete expressionList;
    }

    void addExpression(expression exp)
    {
        expressionList->push_back(exp);
    }

    void setExp(expression exp)
    {
        this->exp = exp;
    }

    expression getExp()
    {
        return this->exp;
    }

    vector<expression> *getExpressionList()
    {
        return expressionList;
    }

    void removeExpressionList()
    {
        while (!expressionList->empty())
        {
            expressionList->pop_back();
        }
    }

    void setHead(ParseTree *head)
    {
        this->head = head;
    }

    ParseTree *getHead()
    {
        return this->head;
    }

    string getRule()
    {
        return this->rule;
    }

    ParseTree *addChild(ParseTree *child)
    {
        this->children->push_back(child);
        return this;
    }

    vector<ParseTree *> *getChildren()
    {
        return this->children;
    }

    bool getIsTerminal()
    {
        return this->isTerminal;
    }

    int getLineBegin()
    {
        return this->lineBegin;
    }

    void setDataType(string dataType)
    {
        this->dataType = dataType;
    }

    string getDataType()
    {
        return this->dataType;
    }

    int getLineEnd()
    {
        return this->lineEnd;
    }

    void printParseTreeRecursive(ofstream &outputFile, ParseTree *node, int depth)
    {
        if (node->getIsTerminal())
        {
            for (int i = 0; i < depth; i++)
            {
                outputFile << " ";
            }
            outputFile << node->getRule() << "\t<Line: " << node->getLineBegin() << ">" << endl;
            return;
        }
        for (int i = 0; i < depth; i++)
        {
            outputFile << " ";
        }
        outputFile << node->getRule() << " \t<Line: " << node->getLineBegin() << "-" << node->getLineEnd() << ">" << endl;
        for (int i = 0; i < node->getChildren()->size(); i++)
        {
            printParseTreeRecursive(outputFile, node->getChildren()->at(i), depth + 1);
        }
    }

    void printParseTree(ofstream &outputFile)
    {
        printParseTreeRecursive(outputFile, this->getHead(), 0);
    }
};

#endif // PARSETREE_CPP
