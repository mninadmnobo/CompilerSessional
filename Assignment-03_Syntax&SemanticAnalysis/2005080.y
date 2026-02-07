/*
yacc --yacc -d --debug 2005080.y -o y.tab.cpp
echo 'step-1: y.tab.cpp and y.tab.hpp created'
flex -o 2005080.cpp 2005080.l
echo 'step-2: scanner created'
g++ -w *.cpp
echo 'step-3: a.out created'
rm 2005080.cpp y.tab.cpp y.tab.hpp
./a.out input.c
rm a.out 


*/











%{
#include<bits/stdc++.h>
#include "2005080_ParseTree.h"
#include "2005080_HelperFunction.h"
#include "2005080_SymbolTable.h"
using namespace std;
int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int yylineno;
ofstream parsetree_file;
ofstream log_file;
ofstream error_file;
int bucketSize=11;
extern expression expressionValues;
int errorCount=0;
SymbolTable *table = new SymbolTable(bucketSize);
HelperFunction *h= new HelperFunction();
int errorLine;
void yyerror(char *s)
{
    errorLine=yylineno;
    errorCount++;
    log_file<<"Error at line no "<<yylineno<<" : syntax error"<<endl;
}



vector<SymbolInfo*> *func_params = new vector<SymbolInfo*>();
vector<SymbolInfo*> *current_dec_list = new vector<SymbolInfo*>();
SymbolInfo* current_function=nullptr;
vector<SymbolInfo*> *delete_symbol_list=new vector<SymbolInfo*>();
bool functionParsed=false;
//bool arrayCheck=false;
string fType="";

void erm_s(SymbolInfo* s) 
{
    if(s!=nullptr)
    { 
       // cout<<1;
        delete s;
        s=nullptr;
    }
}

void erm_h(ParseTree* p) 
{
    if(p!=nullptr)
    {
        delete p;
        p=nullptr;
    }
}

void printError(string str,int line)
{
    error_file<<"Line# "<<line<<": "<<str<<endl;    
}

void delete_symbol(vector<SymbolInfo*>* symbol)
{
    for(int i=0;i<symbol->size();i++)
    {

    }
    delete symbol;
}

void freeMemory()
{
    
        delete table;
        delete_symbol(delete_symbol_list);
        delete func_params;
        delete current_dec_list;
        delete h;

}

%}


%union{
    ParseTree* parseTree;
    SymbolInfo* symbol;
}

%token<symbol> ID LPAREN RPAREN SEMICOLON COMMA LCURL RCURL LSQUARE RSQUARE CONST_INT CONST_FLOAT 
%token<symbol> INT FLOAT VOID FOR IF ELSE LOWER_THAN_ELSE WHILE PRINTLN RETURN
%token<symbol> ADDOP MULOP RELOP LOGICOP ASSIGNOP INCOP DECOP NOT
%type <parseTree> start variable factor term unary_expression simple_expression rel_expression logic_expression expression
%type <parseTree> expression_statement statement statements compound_statement
%type <parseTree> type_specifier var_declaration func_declaration func_definition unit program 
%type <parseTree>  declaration_list parameter_list argument_list arguments
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
        ParseTree *tree = new ParseTree();
        $$ =new ParseTree(false,"start : program",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        tree->setHead($$);
        tree->printParseTree(parsetree_file);
		log_file<<"start : program "<<endl;
        delete tree;
        freeMemory();
        errorCount+=h->returnErrorCount();
        cout<<"Error count "<<errorCount<<endl;
        log_file<<"Total Lines: "<<yylineno<<endl;
        log_file<<"Total Errors: "<<errorCount<<endl;

	}
	;

program : program unit 
    { 
        $$ =new ParseTree(false,"program : program unit",$1->getLineBegin(),$2->getLineEnd());
        $$->addChild($1)->addChild($2);
        log_file<<"program : program unit "<<endl;
    }
	| unit
    {
        $$ =new ParseTree(false,"program : unit",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"program : unit "<<endl;
    }
	;
	
unit : var_declaration
    {
        $$ =new ParseTree(false,"unit : var_declaration",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"unit : var_declaration  "<<endl;
    }    
    | func_declaration
    {
        $$ =new ParseTree(false,"unit : func_declaration",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"unit : func_declaration "<<endl;
    }
    | func_definition
    {
        $$ =new ParseTree(false,"unit : func_definition",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"unit : func_definition  "<<endl;
    }
    ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
    {

        $$ =new ParseTree(false,"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON",$1->getLineBegin(),$6->getLineNo());
        ParseTree* terminalID= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalLPAREN= new ParseTree(true,$3->getType()+" : "+$3->getName(),$3->getLineNo(),$3->getLineNo());
        ParseTree* terminalRPAREN= new ParseTree(true,$5->getType()+" : "+$5->getName(),$5->getLineNo(),$5->getLineNo());
        ParseTree* terminalSEMICOLON= new ParseTree(true,$6->getType()+" : "+$6->getName(),$6->getLineNo(),$6->getLineNo());
        $$->addChild($1)->addChild(terminalID)->addChild(terminalLPAREN)->addChild($4)->addChild(terminalRPAREN)->addChild(terminalSEMICOLON);
        log_file<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON "<<endl;


        if(h->checkSameSymbol(table,$2->getName())==true)
        {
            h->printSameSymbolError("redeclared as different kind of symbol",$2->getLineNo(),error_file);
        }

        if(h->checkRedifinition(func_params)==true)
        {
            h->printErrorRedif("Redefinition of parameter",$2->getLineNo(),error_file);            
        }

        current_function=h->insertFunctionSymbolTable($2,func_params,"DECLARATION",$1->getDataType());
        func_params=new vector<SymbolInfo*>();
        table->insert(current_function);

    }
	| type_specifier ID LPAREN RPAREN SEMICOLON
    {

        $$ =new ParseTree(false,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON",$1->getLineBegin(),$5->getLineNo());
        ParseTree* terminalID= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalLPAREN= new ParseTree(true,$3->getType()+" : "+$3->getName(),$3->getLineNo(),$3->getLineNo());
        ParseTree* terminalRPAREN= new ParseTree(true,$4->getType()+" : "+$4->getName(),$4->getLineNo(),$4->getLineNo());
        ParseTree* terminalSEMICOLON= new ParseTree(true,$5->getType()+" : "+$5->getName(),$5->getLineNo(),$5->getLineNo());
        $$->addChild($1)->addChild(terminalID)->addChild(terminalLPAREN)->addChild(terminalRPAREN)->addChild(terminalSEMICOLON);
        log_file<<"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON "<<endl;

        //semantic analysis

        if(h->checkSameSymbol(table,$2->getName())==true)
        {
            h->printSameSymbolError("redeclared as different kind of symbol",$2->getLineNo(),error_file);
        }
        current_function=h->insertFunctionSymbolTable($2,func_params,"DECLARATION",$1->getDataType());
        func_params=new vector<SymbolInfo*>();
       // delete_symbol_list->push_back(current_function);
        table->insert(current_function);

    }
	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement
    {

        $$ =new ParseTree(false,"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement",$1->getLineBegin(),$6->getLineEnd());
        ParseTree* terminalID= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalLPAREN= new ParseTree(true,$3->getType()+" : "+$3->getName(),$3->getLineNo(),$3->getLineNo());
        ParseTree* terminalRPAREN= new ParseTree(true,$5->getType()+" : "+$5->getName(),$5->getLineNo(),$5->getLineNo());
        $$->addChild($1)->addChild(terminalID)->addChild(terminalLPAREN)->addChild($4)->addChild(terminalRPAREN)->addChild($6);


        //semantic analysis
        bool flag=true;
        if(h->checkSameSymbol(table,$2->getName())==true)
        {
            cout<<"same symbol"<<endl;
            cout<<$2->getName()<<endl;
            flag=false;
            h->printSameSymbolError("redeclared as different kind of symbol",$2->getLineNo(),error_file);
        }
        if(h->checkRedifinition(func_params)==true)
        {
          h->printErrorRedif("Redefinition of parameter",$2->getLineNo(),error_file);            
        }

       // cout<<"Data type"<<$1->getDataType()<<endl;

        if((h->checkConflictingType(table,$1->getDataType(),$2->getName(),"FUNCTION"))==true)
        {
            if(flag==true)
            {
            h->printErrorRedif("Conflicting types for",$2->getLineNo(),error_file);
            }
        }

        

        //cout<<"Function name"<<$2->getName()<<endl;

        if(h->checkConflictingTypeFunctionParameter(table,func_params,$2->getName())==true)
        {
            if(flag==true)
            {
            h->printErrorRedif("Conflicting types for",$2->getLineNo(),error_file);
            }
        }

        flag=true;

        table->printAll(log_file);
        table->exitScope();

        log_file<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl;

        current_function=h->insertFunctionSymbolTable($2,func_params,"DEFINITION",$1->getDataType());
        func_params=new vector<SymbolInfo*>();

        table->insert(current_function);


    }
	| type_specifier ID LPAREN RPAREN compound_statement
    {
        $$ =new ParseTree(false,"func_definition : type_specifier ID LPAREN RPAREN compound_statement",$1->getLineBegin(),$5->getLineEnd());
        ParseTree* terminalID= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalLPAREN= new ParseTree(true,$3->getType()+" : "+$3->getName(),$3->getLineNo(),$3->getLineNo());
        ParseTree* terminalRPAREN= new ParseTree(true,$4->getType()+" : "+$4->getName(),$4->getLineNo(),$4->getLineNo());
        $$->addChild($1)->addChild(terminalID)->addChild(terminalLPAREN)->addChild(terminalRPAREN)->addChild($5);

        table->printAll(log_file);
        table->exitScope();

        if(h->checkSameSymbol(table,$2->getName())==true)
        {
            h->printSameSymbolError("redeclared as different kind of symbol",$2->getLineNo(),error_file);
        }


        if(h->checkConflictingType(table,$1->getDataType(),$2->getName(),"FUNCTION")==true)
        {
            h->printErrorRedif("Conflicting types for",$2->getLineNo(),error_file);
        }

        log_file<<"func_definition : type_specifier ID LPAREN RPAREN compound_statement"<<endl;
        current_function=h->insertFunctionSymbolTable($2,func_params,"DEFINITION",$1->getDataType());
        func_params=new vector<SymbolInfo*>();

        table->insert(current_function);

    }

    |   type_specifier ID LPAREN  error RPAREN compound_statement
    {

        printError("Syntax error at parameter list of function definition",errorLine);
        $$ =new ParseTree(false,"func_definition : type_specifier ID LPAREN error RPAREN compound_statement",$1->getLineBegin(),$6->getLineEnd());
        ParseTree* terminalID= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalLPAREN= new ParseTree(true,$3->getType()+" : "+$3->getName(),$3->getLineNo(),$3->getLineNo());
        ParseTree* terminalRPAREN= new ParseTree(true,$5->getType()+" : "+$5->getName(),$5->getLineNo(),$5->getLineNo());
        $$->addChild($1)->addChild(terminalID)->addChild(terminalLPAREN)->addChild(terminalRPAREN)->addChild($6);
        SymbolInfo* symbol=new SymbolInfo("NN","ID");
        symbol->setDataType($1->getDataType());
        yyerrok;
        table->insert(symbol);
        table->printAll(log_file);
        table->exitScope();
    
    }
 	;				


parameter_list  : parameter_list COMMA type_specifier ID
    {
        $$=new ParseTree(false,"parameter_list : parameter_list COMMA type_specifier ID",$1->getLineBegin(),$4->getLineNo());
        ParseTree* terminalCOMMA= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalID= new ParseTree(true,$4->getType()+" : "+$4->getName(),$4->getLineNo(),$4->getLineNo());
        $$->addChild($1)->addChild(terminalCOMMA)->addChild($3)->addChild(terminalID);
        log_file<<"parameter_list  : parameter_list COMMA type_specifier ID"<<endl;


        //semantic analysis
        $4->setDataType($3->getDataType());
        func_params->push_back($4);
    }
	| parameter_list COMMA type_specifier
    {
        $$=new ParseTree(false,"parameter_list : parameter_list COMMA type_specifier",$1->getLineBegin(),$3->getLineEnd());
        ParseTree* terminalCOMMA= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        $$->addChild($1)->addChild(terminalCOMMA)->addChild($3);
        log_file<<"parameter_list  : parameter_list COMMA type_specifier "<<endl;
    }
 	| type_specifier ID
    {
        $$=new ParseTree(false,"parameter_list : type_specifier ID",$1->getLineBegin(),$2->getLineNo());
        ParseTree* terminalID= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        $$->addChild($1)->addChild(terminalID);
        log_file<<"parameter_list  : type_specifier ID"<<endl;


        //semantic analysis
        $2->setDataType($1->getDataType());
        func_params->push_back($2);
    }
	| type_specifier
    {
        $$=new ParseTree(false,"parameter_list : type_specifier",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"parameter_list : type_specifier "<<endl;
    }
    ;

 		
compound_statement : LCURL statements RCURL
    {
        $$ =new ParseTree(false,"compound_statement : LCURL statements RCURL",$1->getLineNo(),$3->getLineNo());
        ParseTree* terminalLCURL= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalRCURL= new ParseTree(true,$3->getType()+" : "+$3->getName(),$3->getLineNo(),$3->getLineNo());
        $$->addChild(terminalLCURL)->addChild($2)->addChild(terminalRCURL);
        log_file<<"compound_statement : LCURL statements RCURL  "<<endl;

    }
 	| LCURL  RCURL
    {
        $$=new ParseTree(false,"compound_statement : LCURL RCURL",$1->getLineNo(),$2->getLineNo());
        ParseTree* terminalLCURL= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalRCURL= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        $$->addChild(terminalLCURL)->addChild(terminalRCURL);
        log_file<<"compound_statement : LCURL RCURL  "<<endl;
    }
 		    
var_declaration : type_specifier declaration_list SEMICOLON
    {
        $$ =new ParseTree(false,"var_declaration : type_specifier declaration_list SEMICOLON",$1->getLineBegin(),$3->getLineNo());
        ParseTree* terminalSEMICOLON= new ParseTree(true,$3->getType()+" : "+$3->getName(),$3->getLineNo(),$3->getLineNo());
        $$->addChild($1)->addChild($2)->addChild(terminalSEMICOLON);
        log_file<<"var_declaration : type_specifier declaration_list SEMICOLON  "<<endl;
        
        for(int i=0;i<current_dec_list->size();i++)
        {
            if($1->getDataType()!="VOID")
            {
            SymbolInfo* symbol=current_dec_list->at(i);
            cout<<symbol->getName()<<" ";

            symbol->setDataType($1->getDataType());
                if(h->checkSameDataType(table,symbol->getDataType(),symbol->getName())==true)
                {
                    cout<<"conflicting type"<<$3->getLineNo();
                    h->printError("Conflicting types for\'"+symbol->getName()+"\'",$3->getLineNo(),error_file);
                }
                else
                {
                    table->insert(symbol);
                }
            }
            if($1->getDataType()=="VOID")
            {
                h->printError("Variable or field \'"+current_dec_list->at(i)->getName()+"\' declared void",$3->getLineNo(),error_file);
            }
        }
        cout<<endl;
        delete current_dec_list;
        current_dec_list=new vector<SymbolInfo*>();


    }
    | type_specifier error SEMICOLON
    {
        $$ =new ParseTree(false,"var_declaration : type_specifier error SEMICOLON",$1->getLineBegin(),$3->getLineNo());
        ParseTree* terminalSEMICOLON= new ParseTree(true,$3->getType()+" : "+$3->getName(),$3->getLineNo(),$3->getLineNo());
        $$->addChild($1)->addChild(terminalSEMICOLON);
        for(int i=0;i<current_dec_list->size();i++)
        {
            if($1->getDataType()!="VOID")
            {
            SymbolInfo* symbol=current_dec_list->at(i);
            cout<<symbol->getName()<<" ";

            symbol->setDataType($1->getDataType());
                if(h->checkSameDataType(table,symbol->getDataType(),symbol->getName())==true)
                {
                    cout<<"conflicting type"<<$3->getLineNo();
                    h->printError("Conflicting types for\'"+symbol->getName()+"\'",$3->getLineNo(),error_file);
                }
                else
                {
                    table->insert(symbol);
                }
            }
            if($1->getDataType()=="VOID")
            {
                h->printError("Variable or field \'"+current_dec_list->at(i)->getName()+"\' declared void",$3->getLineNo(),error_file);
            }
        }
        cout<<endl;
        delete current_dec_list;
        current_dec_list=new vector<SymbolInfo*>();
        printError("Syntax error at declaration list of variable declaration",errorLine);

    }
    | type_specifier declaration_list error SEMICOLON
    {
        $$ =new ParseTree(false,"var_declaration : type_specifier declaration_list error SEMICOLON",$1->getLineBegin(),$4->getLineNo());
        ParseTree* terminalSEMICOLON= new ParseTree(true,$4->getType()+" : "+$4->getName(),$4->getLineNo(),$4->getLineNo());
        $$->addChild($1)->addChild($2)->addChild(terminalSEMICOLON);
        for(int i=0;i<current_dec_list->size();i++)
        {
            if($1->getDataType()!="VOID")
            {
            SymbolInfo* symbol=current_dec_list->at(i);
            cout<<symbol->getName()<<" ";

            symbol->setDataType($1->getDataType());
                if(h->checkSameDataType(table,symbol->getDataType(),symbol->getName())==true)
                {
                    cout<<"conflicting type"<<$4->getLineNo();
                    h->printError("Conflicting types for\'"+symbol->getName()+"\'",$4->getLineNo(),error_file);
                }
                else
                {
                    table->insert(symbol);
                }
            }
            if($1->getDataType()=="VOID")
            {
                h->printError("Variable or field \'"+current_dec_list->at(i)->getName()+"\' declared void",$4->getLineNo(),error_file);
            }
        }
        cout<<endl;
        delete current_dec_list;
        current_dec_list=new vector<SymbolInfo*>();
        printError("Syntax error at declaration list of variable declaration",errorLine);

    
    }
	;


 		 
type_specifier	: INT
    {
        $$ =new ParseTree(false,"type_specifier : INT",$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalINT= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        $$->addChild(terminalINT);
        $$->setDataType("INT");
        log_file<<"type_specifier	: INT "<<endl;
    }
 	| FLOAT
    {
        $$ =new ParseTree(false,"type_specifier : FLOAT",$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalFLOAT= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        $$->addChild(terminalFLOAT);
        $$->setDataType("FLOAT");
        log_file<<"type_specifier	: FLOAT "<<endl;
    }
 	| VOID
    {
        $$ =new ParseTree(false,"type_specifier : VOID",$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalVOID= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        $$->addChild(terminalVOID);
        $$->setDataType("VOID");
        log_file<<"type_specifier	: VOID"<<endl;
    }
 	;
 		
declaration_list : declaration_list COMMA ID
    {
        $$=new ParseTree(false,"declaration_list : declaration_list COMMA ID",$1->getLineBegin(),$3->getLineNo());
        ParseTree* terminalCOMMA= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalID= new ParseTree(true,$3->getType()+" : "+$3->getName(),$3->getLineNo(),$3->getLineNo());
        $$->addChild($1)->addChild(terminalCOMMA)->addChild(terminalID);
        log_file<<"declaration_list : declaration_list COMMA ID  "<<endl;


        //semantic analysis
        SymbolInfo* symbol=new SymbolInfo($3->getName(),$3->getType());
        current_dec_list->push_back(symbol);
        symbol->setLineNo($3->getLineNo());
        table->insert(symbol);
    }
 	| declaration_list COMMA ID LSQUARE CONST_INT RSQUARE
    {
        $$=new ParseTree(false,"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE",$1->getLineBegin(),$6->getLineNo());
        ParseTree* terminalCOMMA= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalID= new ParseTree(true,$3->getType()+" : "+$3->getName(),$3->getLineNo(),$3->getLineNo());
        ParseTree* terminalLSQUARE= new ParseTree(true,$4->getType()+" : "+$4->getName(),$4->getLineNo(),$4->getLineNo());
        ParseTree* terminalCONST_INT= new ParseTree(true,$5->getType()+" : "+$5->getName(),$5->getLineNo(),$5->getLineNo());
        ParseTree* terminalRSQUARE= new ParseTree(true,$6->getType()+" : "+$6->getName(),$6->getLineNo(),$6->getLineNo());
        $$->addChild($1)->addChild(terminalCOMMA)->addChild(terminalID)->addChild(terminalLSQUARE)->addChild(terminalCONST_INT)->addChild(terminalRSQUARE);
        log_file<<"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE  "<<endl;

        SymbolInfo* symbol=new SymbolInfo($3->getName(),$3->getType());
        current_dec_list->push_back(symbol);
        symbol->setSymbolType("ARRAY");
        symbol->setLineNo($3->getLineNo());

    }
 	| ID
    {
        $$=new ParseTree(false,"declaration_list : ID",$1->getLineNo(),$1->getLineNo());
        
        ParseTree* terminalID= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        $$->addChild(terminalID);
        log_file<<"declaration_list : ID "<<endl;

        SymbolInfo* symbol=new SymbolInfo($1->getName(),$1->getType());
        current_dec_list->push_back(symbol);
        symbol->setLineNo($1->getLineNo());
    }
 	| ID LSQUARE CONST_INT RSQUARE
    {
        $$=new ParseTree(false,"declaration_list : ID LSQUARE CONST_INT RSQUARE",$1->getLineNo(),$4->getLineNo());
        ParseTree* terminalID= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalLSQUARE= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalCONST_INT= new ParseTree(true,$3->getType()+" : "+$3->getName(),$3->getLineNo(),$3->getLineNo());
        ParseTree* terminalRSQUARE= new ParseTree(true,$4->getType()+" : "+$4->getName(),$4->getLineNo(),$4->getLineNo());
        $$->addChild(terminalID)->addChild(terminalLSQUARE)->addChild(terminalCONST_INT)->addChild(terminalRSQUARE);
        log_file<<"declaration_list : ID LSQUARE CONST_INT RSQUARE "<<endl;
        SymbolInfo* symbol=new SymbolInfo($1->getName(),$1->getType());
        current_dec_list->push_back(symbol);
        symbol->setSymbolType("ARRAY");
        symbol->setLineNo($1->getLineNo());
    }
 	;	  
statements : statement
    {
        $$=new ParseTree(false,"statements : statement",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"statements : statement  "<<endl;
    }
	| statements statement
    {
        $$=new ParseTree(false,"statements : statements statement",$1->getLineBegin(),$2->getLineEnd());
        $$->addChild($1)->addChild($2);
        log_file<<"statements : statements statement  "<<endl;
    }
	;   
statement : var_declaration
    {
        $$=new ParseTree(false,"statement : var_declaration",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"statement : var_declaration "<<endl;
    }
	| expression_statement
    {
        $$=new ParseTree(false,"statement : expression_statement",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"statement : expression_statement  "<<endl;
    }
	| compound_statement
    {
        $$=new ParseTree(false,"statement : compound_statement",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"statement : compound_statement "<<endl;
    }
	| FOR LPAREN expression_statement expression_statement expression RPAREN statement
    {
        $$=new ParseTree(false,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement",$3->getLineBegin(),$7->getLineEnd());
        ParseTree* terminalFOR= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalLPAREN= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalRPAREN= new ParseTree(true,$6->getType()+" : "+$6->getName(),$6->getLineNo(),$6->getLineNo());
        $$->addChild(terminalFOR)->addChild(terminalLPAREN)->addChild($3)->addChild($4)->addChild($5)->addChild(terminalRPAREN)->addChild($7);        
        log_file<<"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl;
    }


	| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
    {
        $$=new ParseTree(false,"statement : IF LPAREN expression RPAREN statement",$1->getLineNo(),$5->getLineEnd());
        ParseTree* terminalIF= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalLPAREN= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalRPAREN= new ParseTree(true,$4->getType()+" : "+$4->getName(),$4->getLineNo(),$4->getLineNo());
        $$->addChild(terminalIF)->addChild(terminalLPAREN)->addChild($3)->addChild(terminalRPAREN)->addChild($5);
        log_file<<"statement : IF LPAREN expression RPAREN statement "<<endl;
    }
	| IF LPAREN expression RPAREN statement ELSE statement 
    {
        $$=new ParseTree(false,"statement : IF LPAREN expression RPAREN statement ELSE statement",$3->getLineBegin(),$7->getLineEnd());
        ParseTree* terminalIF= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalLPAREN= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalRPAREN= new ParseTree(true,$4->getType()+" : "+$4->getName(),$4->getLineNo(),$4->getLineNo());
        ParseTree* terminalELSE= new ParseTree(true,$6->getType()+" : "+$6->getName(),$6->getLineNo(),$6->getLineNo());
        $$->addChild(terminalIF)->addChild(terminalLPAREN)->addChild($3)->addChild(terminalRPAREN)->addChild($5)->addChild(terminalELSE)->addChild($7);
        log_file<<"statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl;
    }
	| WHILE LPAREN expression RPAREN statement
    {
        $$=new ParseTree(false,"statement : WHILE LPAREN expression RPAREN statement",$1->getLineNo(),$5->getLineEnd());
        ParseTree* terminalWHILE= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalLPAREN= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalRPAREN= new ParseTree(true,$4->getType()+" : "+$4->getName(),$4->getLineNo(),$4->getLineNo());
        $$->addChild(terminalWHILE)->addChild(terminalLPAREN)->addChild($3)->addChild(terminalRPAREN)->addChild($5);
        log_file<<"statement : WHILE LPAREN expression RPAREN statement "<<endl;
    }
	| PRINTLN LPAREN ID RPAREN SEMICOLON
    {
        $$=new ParseTree(false,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON",$1->getLineNo(),$5->getLineNo());
        ParseTree* terminalPRINTLN= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalLPAREN= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalID= new ParseTree(true,$3->getType()+" : "+$3->getName(),$3->getLineNo(),$3->getLineNo());
        ParseTree* terminalRPAREN= new ParseTree(true,$4->getType()+" : "+$4->getName(),$4->getLineNo(),$4->getLineNo());
        ParseTree* terminalSEMICOLON= new ParseTree(true,$5->getType()+" : "+$5->getName(),$5->getLineNo(),$5->getLineNo());
        $$->addChild(terminalPRINTLN)->addChild(terminalLPAREN)->addChild(terminalID)->addChild(terminalRPAREN)->addChild(terminalSEMICOLON);
        log_file<<"statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<<endl;


    }
	| RETURN expression SEMICOLON
    {
        $$=new ParseTree(false,"statement : RETURN expression SEMICOLON",$1->getLineNo(),$3->getLineNo());
        ParseTree* terminalRETURN= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalSEMICOLON= new ParseTree(true,$3->getType()+" : "+$3->getName(),$3->getLineNo(),$3->getLineNo());
        $$->addChild(terminalRETURN)->addChild($2)->addChild(terminalSEMICOLON);
        log_file<<"statement : RETURN expression SEMICOLON"<<endl;
    
    }
	;
	  
expression_statement : SEMICOLON
    {
        $$=new ParseTree(false,"expression_statement : SEMICOLON",$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalSEMICOLON= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        $$->addChild(terminalSEMICOLON);
        log_file<<"expression_statement : SEMICOLON "<<endl;
        functionParsed=false;
    }			
	| expression SEMICOLON
    {
        $$=new ParseTree(false,"expression_statement : expression SEMICOLON",$1->getLineBegin(),$2->getLineNo());
        ParseTree* terminalSEMICOLON= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        $$->addChild($1)->addChild(terminalSEMICOLON);
        log_file<<"expression_statement : expression SEMICOLON 		 "<<endl;
        functionParsed=false;
    }

    | error  SEMICOLON
    {

        $$=new ParseTree(false,"expression_statement : error SEMICOLON",$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalSEMICOLON= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        $$->addChild(terminalSEMICOLON);
        yyerrok;
        printError("Syntax error at expression of expression statement",errorLine);
        functionParsed=false;
    } 
	;
	  
variable : ID
    {
        $$=new ParseTree(false,"variable : ID",$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalID= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        $$->addChild(terminalID);
        log_file<<"variable : ID 	 "<<endl;

        //semantic analysis
        string type;
        if(table->lookup($1->getName())==nullptr)
        {
            type="NOT DECLARED";
            h->printError("Undeclared variable \'"+$1->getName()+"\'",$1->getLineNo(),error_file);
        }
        else
        {

            SymbolInfo* symbol=table->lookup($1->getName());
            type=symbol->getDataType();
        }
        expression exp;
        exp.id=$1->getName();
        exp.isZero=false;
        exp.dataType=type;
        $$->setExp(exp);

        
     //   func_variables->push_back($1);


    } 		
	| ID LSQUARE expression RSQUARE
    {
        $$=new ParseTree(false,"variable : ID LSQUARE expression RSQUARE",$1->getLineNo(),$4->getLineNo());
        ParseTree* terminalID= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalLSQUARE= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalRSQUARE= new ParseTree(true,$4->getType()+" : "+$4->getName(),$4->getLineNo(),$4->getLineNo());
        $$->addChild(terminalID)->addChild(terminalLSQUARE)->addChild($3)->addChild(terminalRSQUARE);
        log_file<<"variable : ID LSQUARE expression RSQUARE  	 "<<endl;


        //semantic analysis
        string type;
        if(table->lookup($1->getName())==nullptr)
        {
            type="NOT DECLARED";
            h->printError("Undeclared variable \'"+$1->getName()+"\'",$1->getLineNo(),error_file);
        }
        else 
        {
            if(table->lookup($1->getName())->getSymbolType()!="ARRAY")
            {
                type="NOT ARRAY";
                h->printError("\'"+$1->getName()+"\' is not an array",$1->getLineNo(),error_file);
            }
            else{
                SymbolInfo* symbol=table->lookup($1->getName());
                type=symbol->getDataType();
            }
        }

        string dataType=$3->getExp().dataType;
        if(dataType!="INT")
        {
            h->printError("Array subscript is not an integer",$3->getLineBegin(),error_file);
        }
        expression exp;
        exp.id=$1->getName();
        exp.isZero=false;
        exp.dataType=type;
        $$->setExp(exp);

    } 
	;
	 
expression : logic_expression
    {
        $$=new ParseTree(false,"expression : logic_expression",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"expression 	: logic_expression	 "<<endl;
        $$->setExp($1->getExp());
    }
	| variable ASSIGNOP logic_expression
    {
        $$=new ParseTree(false,"expression : variable ASSIGNOP logic_expression",$1->getLineBegin(),$3->getLineEnd());
        ParseTree* terminalASSIGNOP= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        $$->addChild($1)->addChild(terminalASSIGNOP)->addChild($3);
        log_file<<"expression 	: variable ASSIGNOP logic_expression 		 "<<endl;

        string type=h->checkType($1->getExp().dataType,$3->getExp().dataType);

        if(type=="VOID")
        {
            h->printError("Void cannot be used in expression ",$2->getLineNo(),error_file);
        }

        if($1->getExp().dataType=="INT" && $3->getExp().dataType=="FLOAT")
        {
            h->printError("Warning: possible loss of data in assignment of FLOAT to INT",$2->getLineNo(),error_file);
        }
        expression exp;
        exp.id="";
        exp.isZero=false;
        exp.dataType=type;
        $$->setExp(exp);   

    } 	
	;
			
logic_expression : rel_expression 
    {
        $$=new ParseTree(false,"logic_expression : rel_expression",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"logic_expression : rel_expression 	 "<<endl;

        $$->setExp($1->getExp());
    }
	| rel_expression LOGICOP rel_expression 	
    {
        $$=new ParseTree(false,"logic_expression : rel_expression LOGICOP rel_expression",$1->getLineBegin(),$3->getLineEnd());
        ParseTree* terminalLOGICOP= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        $$->addChild($1)->addChild(terminalLOGICOP)->addChild($3);
        log_file<<"logic_expression : rel_expression LOGICOP rel_expression 	 	 "<<endl;

        string type = h->checkType($1->getExp().dataType,$3->getExp().dataType);
        if(type!="INT")
        {
            h->printError("Logical operator cannot be applied other than int",$2->getLineNo(),error_file);
        }
        expression exp;
        exp.id="";
        exp.isZero=false;
        exp.dataType=type;
        $$->setExp(exp);


    }
	;
			
rel_expression	: simple_expression
    {
        $$=new ParseTree(false,"rel_expression : simple_expression",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"rel_expression	: simple_expression "<<endl;


        $$->setExp($1->getExp());

    } 
	| simple_expression RELOP simple_expression
    {
        $$=new ParseTree(false,"rel_expression : simple_expression RELOP simple_expression",$1->getLineBegin(),$3->getLineEnd());
        ParseTree* terminalRELOP= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        $$->addChild($1)->addChild(terminalRELOP)->addChild($3);
        log_file<<"rel_expression	: simple_expression RELOP simple_expression	  "<<endl;

        string type = h->checkType($1->getExp().dataType,$3->getExp().dataType);
        if(type!="INT")
        {
            h->printError("Relational operator cannot be applied other than int",$2->getLineNo(),error_file);
        }
        expression exp;
        exp.id="";
        exp.isZero=false;
        exp.dataType=type;
        $$->setExp(exp);
    }	
	;
				
simple_expression : term
    {
        $$=new ParseTree(false,"simple_expression : term",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"simple_expression : term "<<endl;
        
        $$->setExp($1->getExp());
    } 
	| simple_expression ADDOP term 
    {
        $$=new ParseTree(false,"simple_expression : simple_expression ADDOP term",$1->getLineBegin(),$3->getLineEnd());
        ParseTree* terminalADDOP= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        $$->addChild($1)->addChild(terminalADDOP)->addChild($3);
        log_file<<"simple_expression : simple_expression ADDOP term  "<<endl;

        string type = h->checkType($1->getExp().dataType,$3->getExp().dataType);

        if(type=="VOID")
        {
        //    h->printError("void can not be used in expression",$2->getLineNo(),error_file);
        }
        expression exp;
        exp.id="";
        exp.isZero=false;
        exp.dataType=type;
        $$->setExp(exp);
        
    }
	;
					
term :	unary_expression
    {
        $$=new ParseTree(false,"term : unary_expression",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"term :	unary_expression "<<endl;
        $$->setExp($1->getExp());

    }
    |  term MULOP unary_expression
    {
        $$=new ParseTree(false,"term : term MULOP unary_expression",$1->getLineBegin(),$3->getLineEnd());
        ParseTree* terminalMULOP= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        $$->addChild($1)->addChild(terminalMULOP)->addChild($3);
        log_file<<"term :	term MULOP unary_expression "<<endl;
        string type = h->checkType($1->getExp().dataType,$3->getExp().dataType);
        bool flag=false;
        if(type=="VOID")
        {
        //    h->printError("void can not be used in expression",$2->getLineNo(),error_file);
        }
        if($2->getName()=="%")
        {
            if($1->getExp().dataType=="FLOAT" || $3->getExp().dataType=="FLOAT")
            {
                h->printError("Operands of modulus must be integers ",$2->getLineNo(),error_file);
                type="INT";
            }

            if($3->getExp().isZero)
            {
                h->printError("Warning: division by zero i=0f=1Const=0",$2->getLineNo(),error_file);
                flag=true;
            }
        }
        expression exp;
        exp.id="";
        exp.isZero=flag;
        exp.dataType=type;
        $$->setExp(exp);
    }
    ;

unary_expression : ADDOP unary_expression  
    {
        $$=new ParseTree(false,"unary_expression : ADDOP unary_expression",$2->getLineBegin(),$2->getLineEnd());
        ParseTree* terminalADDOP= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        log_file<<"unary_expression : ADDOP unary_expression "<<endl;
        
        
        $$->setExp($2->getExp());
    }
	| NOT unary_expression
    {
        $$=new ParseTree(false,"unary_expression : NOT unary_expression",$1->getLineNo(),$2->getLineEnd());
        ParseTree* terminalNOT= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        $$->addChild(terminalNOT)->addChild($2);
        log_file<<"unary_expression : NOT unary_expression "<<endl;

        $$->setExp($2->getExp());

    } 
	| factor
    {
        $$=new ParseTree(false,"unary_expression : factor",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"unary_expression : factor "<<endl;


        $$->setExp($1->getExp());
    }
	;
	
factor	: variable
    {
        $$=new ParseTree(false,"factor : variable",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"factor	: variable "<<endl;

        
        
        $$->setExp($1->getExp());


    } 
	| ID LPAREN argument_list RPAREN
    {
        $$=new ParseTree(false,"factor : ID LPAREN argument_list RPAREN",$1->getLineNo(),$4->getLineNo());
        ParseTree* terminalID= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalLPAREN= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        ParseTree* terminalRPAREN= new ParseTree(true,$4->getType()+" : "+$4->getName(),$4->getLineNo(),$4->getLineNo());
        $$->addChild(terminalID)->addChild(terminalLPAREN)->addChild($3)->addChild(terminalRPAREN);
        log_file<<"factor	: ID LPAREN argument_list RPAREN  "<<endl;

        //symanic analysis
      //  cout<<"function call"<<endl;
      //  cout<<$1->getName()<<endl;
        SymbolInfo *func=table->lookup($1->getName());
        string type;
        if(func==nullptr)
        {
           // cout<<$1->getName()<<endl;
            type="NOT DECLARED";
            h->printError("Undeclared function \'"+$1->getName()+"\'",$1->getLineNo(),error_file);
        }
        else
        {
            if(func->getSymbolType()!="FUNCTION")
            {
                type="NOT FUNCTION";
                h->printError(" \'"+$1->getName()+"\' is not a function",$1->getLineNo(),error_file);
            }
            else
            {
               // cout<<$3->getExpressionList()->size()<<endl;
                h->checkFunction(func,$3->getExpressionList(),error_file,$1->getLineNo());
                type=func->getDataType();                
            }

        }

        $3->removeExpressionList();
        expression exp;
        exp.id=$1->getName();
        exp.isZero=false;
        exp.dataType=type;
        $$->setExp(exp);



    }
	| LPAREN expression RPAREN
    {
        $$=new ParseTree(false,"factor : LPAREN expression RPAREN",$1->getLineNo(),$3->getLineNo());
        ParseTree* terminalLPAREN= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalRPAREN= new ParseTree(true,$3->getType()+" : "+$3->getName(),$3->getLineNo(),$3->getLineNo());
        $$->addChild(terminalLPAREN)->addChild($2)->addChild(terminalRPAREN);
        log_file<<"factor	: LPAREN expression RPAREN   "<<endl;



        //symanic analysis
        $$->setExp($2->getExp());



    }
	| CONST_INT
    {
        $$=new ParseTree(false,"factor : CONST_INT",$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalCONST_INT= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        $$->addChild(terminalCONST_INT);
        log_file<<"factor	: CONST_INT   "<<endl;


        expression myexpression;
        const char* cstr = $1->getName().c_str();
        myexpression.value=strtof(cstr,nullptr);
        myexpression.value==0.0?myexpression.isZero=true:myexpression.isZero=false;
        myexpression.dataType="INT";
        $$->setExp(myexpression);


     //   func_variables->push_back($1);
      //  current_factors->push_back($1);
    } 
	| CONST_FLOAT
    {
        $$=new ParseTree(false,"factor : CONST_FLOAT",$1->getLineNo(),$1->getLineNo());
        ParseTree* terminalCONST_FLOAT= new ParseTree(true,$1->getType()+" : "+$1->getName(),$1->getLineNo(),$1->getLineNo());
        $$->addChild(terminalCONST_FLOAT);
        log_file<<"factor	: CONST_FLOAT   "<<endl;



        expression myexpression;
        const char* cstr = $1->getName().c_str();
        myexpression.value=strtof(cstr,nullptr);
        myexpression.value==0.0?myexpression.isZero=true:myexpression.isZero=false;
        myexpression.dataType="FLOAT";
        $$->setExp(myexpression);

       

    //    func_variables->push_back($1);
       // current_factors->push_back($1);

    }
	| variable INCOP
    {
        $$=new ParseTree(false,"factor : variable INCOP",$1->getLineBegin(),$2->getLineNo());
        ParseTree* terminalINCOP= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        $$->addChild($1)->addChild(terminalINCOP);
        log_file<<"factor : variable INCOP "<<endl;

        $$->setExp($1->getExp());

        if($1->getExp().dataType!="INT")
        {
            h->printError("Increment operator can only be used with integer variables",$2->getLineNo(),error_file);
        }


     //   delete func_variables;
     //   func_variables=new vector<SymbolInfo*>();
    } 
	| variable DECOP
    {
        $$=new ParseTree(false,"factor : variable DECOP",$1->getLineBegin(),$2->getLineNo());
        ParseTree* terminalDECOP= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        $$->addChild($1)->addChild(terminalDECOP);
        log_file<<"factor : variable DECOP "<<endl;

        $$->setExp($1->getExp());

        if($1->getExp().dataType!="INT")
        {
            h->printError("Decrement operator can only be used with integer variables",$2->getLineNo(),error_file);
        }


    //    delete func_variables;
    //    func_variables=new vector<SymbolInfo*>();
    }
	;
	
argument_list : arguments
    {
        $$=new ParseTree(false,"argument_list : arguments",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"argument_list : arguments  "<<endl;
        for(int i=0;i<$1->getExpressionList()->size();i++)
        {
            $$->addExpression($1->getExpressionList()->at(i));
        }
    }
	|
    {
        log_file<<"argument_list : "<<endl;
    }
	;
	
arguments : arguments COMMA logic_expression
    {
        $$=new ParseTree(false,"arguments : arguments COMMA logic_expression",$1->getLineBegin(),$3->getLineEnd());
        ParseTree* terminalCOMMA= new ParseTree(true,$2->getType()+" : "+$2->getName(),$2->getLineNo(),$2->getLineNo());
        $$->addChild($1)->addChild(terminalCOMMA)->addChild($3);
        log_file<<"arguments : arguments COMMA logic_expression "<<endl;
        $1->addExpression($3->getExp());
        for(int i=0;i<$1->getExpressionList()->size();i++)
        {
            $$->addExpression($1->getExpressionList()->at(i));
        }

    }
	| logic_expression
    {
        $$=new ParseTree(false,"arguments : logic_expression",$1->getLineBegin(),$1->getLineEnd());
        $$->addChild($1);
        log_file<<"arguments : logic_expression"<<endl;
        
        $$->addExpression($1->getExp());
    }
	;
 

%%
int main(int argc,char *argv[])
{
    FILE *fp;
	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot open input file.\n");
		exit(1);
	}
    string input_file_name = argv[1];
	string parsetree_file_name = input_file_name.substr(0,input_file_name.size()-2) + "_parsetree.txt";
    string log_file_name = input_file_name.substr(0,input_file_name.size()-2) + "_log.txt";
    string error_file_name = input_file_name.substr(0,input_file_name.size()-2) + "_error.txt";
    parsetree_file.open(parsetree_file_name);
    log_file.open(log_file_name);
    error_file.open(error_file_name);
	yyin=fp;
	yyparse();
    parsetree_file.close();
    log_file.close();
    error_file.close();
	return 0;
}

