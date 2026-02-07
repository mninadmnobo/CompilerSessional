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
#include "2005080_SymbolTable.h"
#include <string>
int wordcount = 0;
FILE *token_file; 
FILE *log_file;
bool singleLineString;
int tempCount = 0;

int errorCount = 0;
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

struct SymbolTypePair symbolTypePairs[] = { 
    {"+", "ADDOP"}, 
    {"-", "ADDOP"}, 
    {"*", "MULOP"}, 
    {"/", "MULOP"}, 
    {"%", "MULOP"}, 
    {"++", "INCOP"}, 
    {"--", "INCOP"}, 
    {"<", "RELOP"}, 
    {"<=", "RELOP"},
    {">", "RELOP"}, 
    {">=", "RELOP"}, 
    {"==", "RELOP"}, 
    {"!=", "RELOP"}, 
    {"=", "ASSIGNOP"}, 
    {"&&", "LOGICOP"}, 
    {"||", "LOGICOP"}, 
    {"&", "BITOP"}, 
    {"|", "BITOP"}, 
    {"^", "BITOP"}, 
    {"<<", "BITOP"}, 
    {">>", "BITOP"}, 
    {"!", "NOT"}, 
    {"(", "LPAREN"}, 
    {")", "RPAREN"}, 
    {"{", "LCURL"}, 
    {"}", "RCURL"}, 
    {"[", "LSQUARE"}, 
    {"]", "RSQUARE"}, 
    {",", "COMMA"}, 
    {";", "SEMICOLON"}, 
}; 

const char* removeLastCharacter(const char* input) {
    if (input == nullptr || input[0] == '\0') {
        return input;
    }
    char* result = new char[strlen(input)];
    strncpy(result, input, strlen(input) - 1);
    result[strlen(input) - 1] = '\0';
    return result;
}




SymbolTable *symbolTable=new SymbolTable(10);

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

void writeToLogFile(FILE* log_file,const char* YYTEXT, const char* yytext, int yylineno) {
    char buffer[1000];
    snprintf(buffer, sizeof(buffer), "Line# %d: Token <%s> Lexeme %s found", yylineno, YYTEXT, yytext);
    fprintf(log_file, "%s\n", buffer);
    fflush(log_file);
}

void checkIndenation()
{
    if(spaceCount)
    {
        char buffer[1000];
        snprintf(buffer, sizeof(buffer), "Line# %d: Warning, tab requrired but got space.\n", yylineno);
        warningCount++;
        fprintf(log_file, "%s", buffer);
    }
    else if(tabCount!=currentIndentTab)
    {
        char buffer[1000];
        //warning, 1 of tabs needed but got 2 tabs.
        warningCount++;
        snprintf(buffer, sizeof(buffer), "Line# %d: warning, %d of tabs needed but got %d tabs.\n", yylineno,currentIndentTab,tabCount);
        fprintf(log_file, "%s", buffer);
    }
    return;
}


void printEnd()
{
    symbolTable->printAll(log_file);
    fprintf(log_file, "Total lines: %d\n", yylineno);
    fprintf(log_file, "Total errors: %d\n", errorCount);
    fprintf(log_file, "Total warnings: %d\n", warningCount);
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


if|else|while|for|do|break|int|char|float|double|void|return|switch|case|default|continue {
    writeToTokenFile(token_file,convertToUppercase(yytext), yytext);
    writeToLogFile(log_file,convertToUppercase(yytext), yytext, yylineno);
    }

{EXCEPT_NEWLINE} {wc();}
\+|\-|\*|\/|%|\+\+|\-\-|<|<=|>|>=|==|!=|=|&&|\|\||\|&|^|\(\(|\)\)|!|\(|\)|\{|\}|\[|\]|\,|\;|<<|>> {
    if(string(yytext)=="{")
    {
        currentIndentTab++;
        symbolTable->enterScope();
    }
    else if(string(yytext)=="}")
    {
        currentIndentTab--;
        symbolTable->exitScope();
    }
    writeToTokenFile(token_file,getType(yytext, symbolTypePairs, sizeof(symbolTypePairs) / sizeof(symbolTypePairs[0])), yytext);
    writeToLogFile(log_file,getType(yytext, symbolTypePairs, sizeof(symbolTypePairs) / sizeof(symbolTypePairs[0])), yytext, yylineno);
    }
\| {
        writeToTokenFile(token_file,"BITOP", yytext);
        writeToLogFile(log_file,"BITOP", yytext, yylineno);
    }
\& {
        //cout<<yytext<<endl;
        writeToTokenFile(token_file,"BITOP", yytext);
        writeToLogFile(log_file,"BITOP", yytext, yylineno);
}

{ID} {
    writeToTokenFile(token_file,"ID", yytext);
    writeToLogFile(log_file,"ID", yytext, yylineno);
    if(symbolTable->insert(new SymbolInfo(yytext, "ID")))
    {
        symbolTable->printAll(log_file);
    }
    else
    {
        fprintf(log_file,"\t%s already exists in the current ScopeTable\n", yytext);
    }
    }

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
    //cout<<"ehw";
    //cout<<yytext<<endl;
    strcat(logString, yytext);
    strcat(tokenString, yytext);
}
<STRING_START>\" {
    //cout<<"ehw";
    //cout<<logString<<endl;
    strcat(logString, "\"");
    //cout<<logString<<endl;
    if(singleLineString)
    {
        writeToTokenFile(token_file,"SINGLE LINE STRING", tokenString);
        writeToLogFile(log_file,"SINGLE LINE STRING", logString, yylineno);
        yylineno+=tempCount;
        BEGIN INITIAL;
    }
    else
    {
        writeToTokenFile(token_file,"MULTI LINE STRING", tokenString);
        writeToLogFile(log_file,"MULTI LINE STRING", logString, yylineno);
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
   // cout<<logString<<endl;
    strcat(logString, yytext);
    strcat(tokenString, yytext);

}
<STRING_START>\n {
    yylineno+=tempCount;
    writeErrorToLogFile(log_file,"UNFINISHED_STRING",logString,yylineno);
    yylineno++;
    errorCount++;
    BEGIN INITIAL;
}
\/\/ {
    //cout<<"inside comment343"<<endl;
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
    writeToLogFile(log_file,"MULTI LINE COMMENT", commentString.c_str(), yylineno);
    yylineno+=tempCount;
    BEGIN INITIAL;
}
<COMMENT_ASTERISK><<EOF>> {
    yylineno+=tempCount;
    writeErrorToLogFile(log_file,"UNFINISHED_COMMENT",commentString.c_str(),yylineno);
    errorCount++;
    printEnd();
    fclose(token_file);
    fclose(log_file);
    exit(0);
    
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
        writeToLogFile(log_file,"SINGLE LINE COMMENT", str.c_str(), yylineno);
        yylineno+=tempCount+1;
        BEGIN INITIAL;
}
<COMMENT><<EOF>> {
        writeToLogFile(log_file,"SINGLE LINE COMMENT", commentString.c_str(), yylineno);
        yylineno+=tempCount;
        printEnd();
        fclose(token_file);
        fclose(log_file);
        exit(0);
    
}



<CHAR_LITERAL>{CHAR_SPECIAL}\' {
    cout<<"inside yyspecial"<<yytext<<endl;
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
    writeToTokenFile(token_file,"CONST_CHAR", temp2);
    writeToLogFile(log_file,"CONST_CHAR", temp2, yylineno);
    free((void*)temp);
    BEGIN INITIAL;
    }
<CHAR_LITERAL>[a-zA-Z0-9]\' {
    const char* temp=removeLastCharacter(yytext);
    writeToTokenFile(token_file,"CONST_CHAR",temp);
    writeToLogFile(log_file,"CONST_CHAR", temp, yylineno);
    free((void*)temp);
    BEGIN INITIAL;
    }
<CHAR_LITERAL>([a-zA-Z0-9 ])+\' {
    writeErrorToLogFile(log_file,"MULTICHAR_CONST_CHAR",strcat(charString,yytext),yylineno);
    errorCount++;
    BEGIN INITIAL;
    }
<CHAR_LITERAL>\' {
    writeErrorToLogFile(log_file,"EMPTY_CONST_CHAR",strcat(charString,yytext),yylineno);
    errorCount++;
    BEGIN INITIAL;
    }
<CHAR_LITERAL>.|[\\][\'] {
    //cout<<strcat(charString,yytext)<<endl;
    writeErrorToLogFile(log_file,"UNFINISHED_CONST_CHAR",strcat(charString,yytext),yylineno);
    errorCount++;
    BEGIN INITIAL;
    }
<CHAR_LITERAL>[\n] {
    //cout<<"times"<<endl;
    writeErrorToLogFile(log_file,"UNFINISHED_CONST_CHAR",charString,yylineno);
    errorCount++;
    yylineno++;
    BEGIN INITIAL;
    }
{DIGIT}+ {
    writeToTokenFile(token_file,"CONST_INT", yytext);
    writeToLogFile(log_file,"CONST_INT", yytext, yylineno);
    }
{CONST_FLOAT} {
    writeToTokenFile(token_file,"CONST_FLOAT", yytext);
    writeToLogFile(log_file,"CONST_FLOAT", yytext, yylineno);
    }

{TOO_DEC} {
    writeErrorToLogFile(log_file,"TOO_MANY_DECIMAL_POINTS",yytext,yylineno);
    errorCount++;
    }
{ILL_NUM} {
    writeErrorToLogFile(log_file,"ILLFORMED_NUMBER",yytext,yylineno);
    errorCount++;
}
{INVALID_SUFFIX_PREFIX} {
    writeErrorToLogFile(log_file,"INVALID_ID_SUFFIX_NUM_PREFIX",yytext,yylineno);
    errorCount++;
}

. {
    writeErrorToLogFile(log_file,"UNRECOGNIZED_CHAR",yytext,yylineno);
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
  //  cout<<"inside newline";
    tabCount = 0;
    spaceCount = 0;
    yylineno++;
    }

<INDENTATION>. {
    if(strcmp(yytext,"}")==0)
    {
       // cout<<"First check"<<endl;
      // cout<<currentIndentTab<<endl;
      //  cout<<tabCount<<endl;
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
    printEnd();
    fclose(token_file);
    fclose(log_file);
    exit(0);
}


%%
int main(int argc, char *argv[])
{
    if (argc > 3) // Need both input and output file names
    {
        FILE *fp = fopen(argv[1], "r");
        if (fp)
        {
            yyin = fp;
        }
        else
        {
            printf("File not found\n");
            exit(1);
        }

        token_file = fopen(argv[2], "w");
        if (!token_file)
        {
            printf("Error opening output file\n");
            exit(1);
        }
        log_file = fopen(argv[3], "w");
        if (!log_file)
        {
            printf("Error opening output file\n");
            exit(1);
        }
    }
    else
    {
        printf("Usage: %s input_file output_file\n", argv[0]);
        exit(1);
    }
    yylex();
    fclose(yyin);
    fclose(token_file);
    fclose(log_file);
    return 0;
}
