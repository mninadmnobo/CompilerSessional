%option noyywrap
%x CHAR_LITERAL
%x STRING_START
%x COMMENT
%x COMMENT_ASTERISK
%x INDENTATION

%{
#include<stdio.h>
#include<ctype.h>
#include<string.h>
#include<bits/stdc++.h>
#include "2005107_SymbolInfo.h"
#include "2005107_ParseTree.h"
#include "2005107_SymbolTable.h"
#include "2005107_HelperFunction.h"
#include "y.tab.hpp"
using namespace std;
extern YYSTYPE yylval;
extern ofstream log_file;
extern SymbolTable *table;
extern vector<SymbolInfo*> *func_params;
int wordcount = 0;
bool singleLineString;
int tempCount = 0;

extern int errorCount;
bool checkIndent = false;


int spaceCount = 0;
int tabCount = 0;
int currentIndentTab = 0;

void wc()
{

}

bool singleLineComment;
string commentString;
char charString[5]="'";

char tokenString[500]="";
char logString[500]="";
int warningCount=0;
HelperFunction *h2= new HelperFunction();
extern vector<SymbolInfo*> *func_variables;
extern vector<SymbolInfo*> *delete_symbol_list;



struct SymbolTypePair { 
    const char* symbol; 
    const char* type; 
};

const char* getType(const char* symbol, const struct SymbolTypePair* symbolTypePairs, size_t numPairs) { 
    for (size_t i = 0; i < numPairs; ++i) { 
        if (strcmp(symbol, symbolTypePairs[i].symbol) == 0) { 
            return symbolTypePairs[i].type;  
        } 
    } 
    return "UNKNOWN";
} 


const char* removeLastCharacter(const char* input) {
    if (input == nullptr || input[0] == '\0') {
        return input;
    }
    char* result = new char[strlen(input)];
    strncpy(result, input, strlen(input) - 1);
    result[strlen(input) - 1] = '\0';
    return result;
}


void writeToTokenFile(FILE* token_file,const char*YYTEXT, const char* yytext) {
    char buffer[1000];
    snprintf(buffer, sizeof(buffer), "<%s, %s>", YYTEXT, yytext);
    fprintf(token_file, "%s\n", buffer);
    fflush(token_file);
}
void writeErrorToLogFile( FILE* log_file,const char* yytext,const char* yytext2, int yylineno) {
    char buffer[1000];
    snprintf(buffer, sizeof(buffer), "Error at line# %d: %s %s", yylineno, yytext,yytext2);
    fprintf(log_file, "%s\n", buffer);
    fflush(log_file);
}

void writeToLogFile(const char* YYTEXT, const char* yytext, int yylineno) {
    log_file<<"Line# "<<yylineno<<": "<<"Token <"<<YYTEXT<<">"<<" Lexeme "<<yytext<<" found"<<endl;
}

void checkIndenation()
{
    if(spaceCount)
    {
        char buffer[1000];
        warningCount++;
    }
    else if(tabCount!=currentIndentTab)
    {
        char buffer[1000];
        warningCount++;

    }
    return;
}





char* convertToUppercase(const char* input)
{
    char* result = strdup(input);

    for (int i = 0; result[i]; i++)
    {
        result[i] = toupper(result[i]);
    }

    return result;
}
%}

EXCEPT_NEWLINE [ \t\v\f\r]
ALPHABET [a-zA-Z_]
ALPHANUMERIC [a-zA-Z0-9_]
ID {ALPHABET}{ALPHANUMERIC}*
DIGIT [0-9]
CONST_FLOAT {DIGIT}*(\.{DIGIT}+)?([Ee][+-]?{DIGIT}+)?
CHAR_SPECIAL (\"|\\n|\\t|\\'|\\\\|\\a|\\b|\\f|\\r|\\v|\\0)
STRING_CHARS (\\n|\\t|\\v|\\f|\\r)
TOO_DEC {DIGIT}+((\.)+{DIGIT}+)+(E(\.)*[+-]?(\.)*{DIGIT})?(\.)*{DIGIT}*
ILL_NUM ({DIGIT}|{CONST_FLOAT})[E]+{CONST_FLOAT}|{DIGIT}
INVALID_SUFFIX_PREFIX {CONST_FLOAT}{ID}|{ID}{CONST_FLOAT}

%%
{EXCEPT_NEWLINE} {wc();}

println { 
    writeToLogFile("PRINTLN",yytext,yylineno);
    yylval.symbol=new SymbolInfo(yytext,"PRINTLN"); 
    yylval.symbol->setLineNo(yylineno);  
    delete_symbol_list->push_back(yylval.symbol);
    return PRINTLN;
    }
if {  
    writeToLogFile("IF",yytext,yylineno);
    yylval.symbol=new SymbolInfo(yytext,"IF"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return IF;
    }
else { 
    writeToLogFile("ELSE",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"ELSE"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return ELSE;
    }
for { 
    writeToLogFile("FOR",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"FOR");
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return FOR; 
    }
while { 
    writeToLogFile("WHILE",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"WHILE"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return WHILE;
    }
int { 
    writeToLogFile("INT",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"INT"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return INT;
    }
float { 
    writeToLogFile("FLOAT",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"FLOAT"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return FLOAT;
    }
void { 
    writeToLogFile("VOID",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"VOID"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return VOID; }
return { 
    writeToLogFile("RETURN",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"RETURN"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return RETURN;}
[+-] {  
    writeToLogFile("ADDOP",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"ADDOP"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return ADDOP;}
[*/%] { 
    writeToLogFile("MULOP",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"MULOP"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return MULOP;}
"++" { 
    writeToLogFile("INCOP",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"INCOP"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return INCOP;}
"--" {
    writeToLogFile("DECOP",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"DECOP"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return DECOP;}
\<|"<="|\>|">="|"=="|"!=" {
    writeToLogFile("RELOP",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"RELOP"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return RELOP;}
\= {
    writeToLogFile("ASSIGNOP",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"ASSIGNOP");
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return ASSIGNOP;}
"&&"|"||" {
    writeToLogFile("LOGICOP",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"LOGICOP"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return LOGICOP; }
\! {
    writeToLogFile("NOT",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"NOT"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return NOT;}
\( {

    writeToLogFile("LPAREN",yytext,yylineno);
     yylval.symbol=new SymbolInfo(yytext,"LPAREN"); 
     yylval.symbol->setLineNo(yylineno);
     delete_symbol_list->push_back(yylval.symbol);
     return LPAREN;}
\) {
    writeToLogFile("RPAREN",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"RPAREN"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return RPAREN;}
\{ {
    writeToLogFile("LCURL",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"LCURL");
    currentIndentTab++;
    yylval.symbol->setLineNo(yylineno);
    table->enterScope();
    h2->checkRedifinition(func_params);
    for(int i=0;i<func_params->size();i++)
    {
        delete_symbol_list->push_back(func_params->at(i));
        table->insert(new SymbolInfo(func_params->at(i)->getName(),func_params->at(i)->getType(),func_params->at(i)->getDataType(),func_params->at(i)->getSymbolType()));
    }
    cout<<"Scope entered"<<endl;
    return LCURL;
    }
\} {
    writeToLogFile("RCURL",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"RCURL"); 
    currentIndentTab++; 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return RCURL;}
\[ {
    writeToLogFile("LSQUARE",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"LSQUARE"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return LSQUARE;}
\] {
    writeToLogFile("RSQUARE",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"RSQUARE");
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return RSQUARE;}
\, {
    writeToLogFile("COMMA",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"COMMA"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return COMMA;}
\; {
    writeToLogFile("SEMICOLON",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"SEMICOLON"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return SEMICOLON;}
{ID} {
    writeToLogFile("ID",yytext,yylineno); 
    yylval.symbol=new SymbolInfo(yytext,"ID"); 
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return ID;}


\' {
    strncpy(charString, "'",2);
    BEGIN CHAR_LITERAL;

}

\" {
    tempCount=0;
    BEGIN STRING_START;
    strncpy(tokenString, "",1);
    strncpy(logString, "",1);
    singleLineString=true;
    strcat(logString, "\"");


}
<STRING_START>\\\" {
    strcat(logString, yytext);
    strcat(tokenString, yytext);
}
<STRING_START>\" {
    strcat(logString, "\"");
    if(singleLineString)
    {
      //  writeToTokenFile(token_file,"SINGLE LINE STRING", tokenString);
       // writeToLogFile("SINGLE LINE STRING", logString, yylineno);
        yylineno+=tempCount;
        BEGIN INITIAL;
    }
    else
    {
     //   writeToTokenFile(token_file,"MULTI LINE STRING", tokenString);
      //  writeToLogFile("MULTI LINE STRING", logString, yylineno);
        yylineno+=tempCount;
        BEGIN INITIAL;
       
    }
}
<STRING_START>{STRING_CHARS} {
    strcat(logString, yytext);
    if (strcmp(yytext, "\\n") == 0) {
        strcat(tokenString, "\n");
    } 
    else if (strcmp(yytext, "\\t") == 0) {
        strcat(tokenString, "\t");
    } 
    else if (strcmp(yytext, "\\v") == 0) {
        strcat(tokenString, "\v");
    } 
    else if (strcmp(yytext, "\\f") == 0) {
        strcat(tokenString, "\f");
    } 
    else if (strcmp(yytext, "\\r") == 0) {
        strcat(tokenString, "\r");
    } 
}

<STRING_START>\\({EXCEPT_NEWLINE}*)[\n] {

    singleLineString=false;
    strcat(logString, yytext);
    tempCount++;
    
}
<STRING_START>[^\n] {
    strcat(logString, yytext);
    strcat(tokenString, yytext);

}
<STRING_START>\n {
    yylineno+=tempCount;
    log_file<<"Error at line# "<<yylineno<<": "<<"UNFINISHED_STRING"<<endl;
    //writeErrorToLogFile("UNFINISHED_STRING",logString,yylineno);
    yylineno++;
    errorCount++;
    BEGIN INITIAL;
}
\/\/ {
    tempCount=0;
    singleLineComment=true;
    commentString="//";
    BEGIN COMMENT;
}
\/\* {
    commentString="";
    BEGIN COMMENT_ASTERISK;
    tempCount=0;
    commentString+="/*";
}
<COMMENT_ASTERISK>. {
    string cppString(yytext);
    commentString+=cppString;
}
<COMMENT_ASTERISK>[\n] {
    tempCount++;
    string cppString(yytext);
    commentString+=cppString;
}
<COMMENT_ASTERISK>\*\/ {
    string cppString(yytext);
    commentString+=cppString;
    log_file<<"Error at line# "<<yylineno<<": "<<"MULTI LINE COMMENT"<<endl;
    
  //  writeToLogFile("MULTI LINE COMMENT", commentString.c_str(), yylineno);
    yylineno+=tempCount;
    BEGIN INITIAL;
}
<COMMENT_ASTERISK><<EOF>> {
    delete h2;
    yylineno+=tempCount;
    log_file<<"Error at line# "<<yylineno<<": "<<"UNFINISHED_COMMENT"<<endl;
   // writeErrorToLogFile(log_file,"UNFINISHED_COMMENT",commentString.c_str(),yylineno);
    errorCount++;
   // printEnd();
    //fclose(token_file);
   // fclose(log_file);
    return 0;
    
}

<COMMENT>[^\n] {
    string cppString(yytext);
    commentString+=cppString;
}

<COMMENT>[\\]({EXCEPT_NEWLINE})*[\n] {
    singleLineComment=false;
    tempCount++;
    string cppString(yytext);
    commentString+=cppString;
}
<COMMENT>\n { 
        char buffer[500];
        string str;
        str.assign(commentString);
        str.erase(str.find_last_not_of(" \n\r\t")+1);
      //  writeToLogFile(log_file,"SINGLE LINE COMMENT", str.c_str(), yylineno);
        yylineno+=tempCount+1;
        BEGIN INITIAL;
}
<COMMENT><<EOF>> {
    delete h2;
     //  writeToLogFile(log_file,"SINGLE LINE COMMENT", commentString.c_str(), yylineno);
        yylineno+=tempCount;
       // printEnd();
       // fclose(token_file);
       // fclose(log_file);
        return 0;
    
}



<CHAR_LITERAL>{CHAR_SPECIAL}\' {
    const char* temp=removeLastCharacter(yytext);
    char* temp2=new char[1];
    if (strcmp(temp, "\\'") == 0) {
        temp2[0]='\'';
    } 
    else if (strcmp(temp, "\\n") == 0) {
        temp2[0]='\n';
    } 
    else if (strcmp(temp, "\\t") == 0) {
        temp2[0]='\t';
    } 
    else if (strcmp(temp, "\\v") == 0) {
        temp2[0]='\v';
    } 
    else if (strcmp(temp, "\\f") == 0) {
        temp2[0]='\f';
    } 
    else if (strcmp(temp, "\\r") == 0) {
        temp2[0]='\r';
    } 
    else if (strcmp(temp, "\\a") == 0) {
        temp2[0]='\a';
    } 
    else if (strcmp(temp, "\\b") == 0) {
        temp2[0]='\b';
    } 
    else if (strcmp(temp, "\\0") == 0) {
        temp2[0]='\0';
    } 
    else if (strcmp(temp, "\\\\") == 0) {
        temp2[0]='\\';
    } 
   // writeToTokenFile(token_file,"CONST_CHAR", temp2);
    writeToLogFile("CONST_CHAR", temp2, yylineno);
    free((void*)temp);
    BEGIN INITIAL;
    }
<CHAR_LITERAL>[a-zA-Z0-9]\' {
    const char* temp=removeLastCharacter(yytext);
   // writeToTokenFile(token_file,"CONST_CHAR",temp);
    writeToLogFile("CONST_CHAR", temp, yylineno);
    free((void*)temp);
    BEGIN INITIAL;
    }
<CHAR_LITERAL>([a-zA-Z0-9 ])+\' {
    log_file<<"Error at line# "<<yylineno<<": "<<"MULTICHAR_CONST_CHAR"<<endl;
   // writeErrorToLogFile(log_file,"MULTICHAR_CONST_CHAR",strcat(charString,yytext),yylineno);
    errorCount++;
    BEGIN INITIAL;
    }
<CHAR_LITERAL>\' {
    log_file<<"Error at line# "<<yylineno<<": "<<"EMPTY_CONST_CHAR"<<endl;
   // writeErrorToLogFile(log_file,"EMPTY_CONST_CHAR",strcat(charString,yytext),yylineno);
    errorCount++;
    BEGIN INITIAL;
    }
<CHAR_LITERAL>.|[\\][\'] {
    log_file<<"Error at line# "<<yylineno<<": "<<"UNFINISHED_CONST_CHAR"<<endl;
   // writeErrorToLogFile(log_file,"UNFINISHED_CONST_CHAR",strcat(charString,yytext),yylineno);
    errorCount++;
    BEGIN INITIAL;
    }
<CHAR_LITERAL>[\n] {
    log_file<<"Error at line# "<<yylineno<<": "<<"UNFINISHED_CONST_CHAR"<<endl;
    //writeErrorToLogFile(log_file,"UNFINISHED_CONST_CHAR",charString,yylineno);
    errorCount++;
    yylineno++;
    BEGIN INITIAL;
    }
{DIGIT}+ {
    writeToLogFile("CONST_INT",yytext,yylineno);
    yylval.symbol=new SymbolInfo(yytext,"CONST_INT");
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return CONST_INT;
    //writeToLogFile(log_file,"CONST_INT", yytext, yylineno);
    }
{CONST_FLOAT} {
    yylval.symbol=new SymbolInfo(yytext,"CONST_FLOAT");
    writeToLogFile("CONST_FLOAT",yytext,yylineno);
    yylval.symbol->setLineNo(yylineno);
    delete_symbol_list->push_back(yylval.symbol);
    return CONST_FLOAT;
   // writeToTokenFile(token_file,"CONST_FLOAT", yytext);
   // writeToLogFile(log_file,"CONST_FLOAT", yytext, yylineno);
    }

{TOO_DEC} {
    log_file<<"Error at line# "<<yylineno<<": "<<"TOO_DEC"<<yytext<<endl;
    errorCount++;
    }
{ILL_NUM} {
    log_file<<"Error at line# "<<yylineno<<": "<<"ILL_NUM"<<yytext<<endl;
   // writeErrorToLogFile(log_file,"ILLFORMED_NUMBER",yytext,yylineno);
    errorCount++;
}
{INVALID_SUFFIX_PREFIX} {
    log_file<<"Error at line# "<<yylineno<<": "<<"INVALID_SUFFIX_PREFIX"<<yytext<<endl;
  //  writeErrorToLogFile(log_file,"INVALID_ID_SUFFIX_NUM_PREFIX",yytext,yylineno);
    errorCount++;
}

. {
    log_file<<"Error at line# "<<yylineno<<": "<<"UNRECOGNIZED_CHAR"<<yytext<<endl;
   // writeErrorToLogFile(log_file,"UNRECOGNIZED_CHAR",yytext,yylineno);
    errorCount++;
}


[\n] {
    yylineno++;
    spaceCount = 0;
    tabCount = 0;
    BEGIN INDENTATION;
    }
<INDENTATION>[ \t\v\f\r] {
    if(strcmp(yytext,"\t")==0)
    {
        tabCount++;
    }
    else if(strcmp(yytext," ")==0)
    {
        spaceCount++;
    }
}
<INDENTATION>\n {
    tabCount = 0;
    spaceCount = 0;
    yylineno++;
    }

<INDENTATION>. {
    if(strcmp(yytext,"}")==0)
    {
        currentIndentTab--;
        checkIndenation();
        currentIndentTab++;
    }
    else
    {
    checkIndenation();
    }
    yyless(0);
    BEGIN INITIAL;
}



<<EOF>> {
    delete h2;
    return 0;
}


%%