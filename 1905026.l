%option noyywrap

%x MULTI_COMMENT_STATE

%{

#include<bits/stdc++.h>

#include "SymbolTable.h"

using namespace std;

int lineCount = 1;
int errorCount = 0;

string comment;

ofstream logOutput;
ofstream tokenOutput;

int bucketSize = 10;
SymbolTable symbolTable(bucketSize);

int countNewLines(string str){
	int count = 0;
	for(int i=0;i<str.length();i++){
		if(str[i]=='\n')
			count++;
	}
	return count;
}

/*get actual string from the string literal*/
string getPrintableString(string str){
	string result = "";
	for(int i=0;i<str.length();i++){
		if(str[i]=='\\'){
			if(str[i+1]=='n')
				result += '\n';
			if(str[i+1]=='t')
				result += '\t';
			if(str[i+1]=='a')
				result += '\a';
			if(str[i+1]=='f')
				result += '\f';
			if(str[i+1]=='r')
				result += '\r';
			if(str[i+1]=='b')
				result += '\b';
			if(str[i+1]=='v')
				result += '\v';
			if(str[i+1]=='0')
				result += '\0';
			if(str[i+1]=='\\')
				result += '\\';
			if(str[i+1]=='\'')
				result += '\'';
			if(str[i+1]=='\"')
				result += '\"';
			i++;
		}
		else if(str[i]=='\n'){
			lineCount++;
			// result += str[i];
		}
		else result += str[i];
	}
	return result;
}

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z_]
DIGIT [0-9]
ALPHA_NUMERIC [a-zA-Z_0-9]
NEWLINE [\r]?\n
KEYWORDS if|else|for|while|do|break|int|char|float|double|void|return|switch|case|default|continue

%%

{WHITESPACE} {}

{NEWLINE} {lineCount++;}

{KEYWORDS}	{
	string token = "",temp=yytext;
	for(char ch:temp)token+=toupper(ch);
	tokenOutput<<"<"<<token<<", "<<yytext<<">"<<endl;
	logOutput<<"Line# "<<lineCount<<": Token <"<<token<<"> Lexeme "<<yytext<<" found"<<endl;
}

{LETTER}{ALPHA_NUMERIC}*	{
	tokenOutput<<"<ID, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <ID> Lexeme "<<yytext<<" found"<<endl;
	string temp=yytext;
	if(symbolTable.insertSymbol(temp,"ID")){
		symbolTable.printAllScope(logOutput);
	}
	else {
		logOutput<<"\t"<<yytext<<" already exisits in the current ScopeTable"<<endl;
	}
}

{DIGIT}+	{
	tokenOutput<<"<CONST_INT, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<<lineCount<<": Token <CONST_INT> Lexeme "<<yytext<<" found"<<endl;	
}

{DIGIT}*(\.{DIGIT}+)?([Ee][+-]?{DIGIT}+)?	{
	tokenOutput<<"<CONST_FLOAT, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <CONST_FLOAT> Lexeme "<<yytext<<" found"<<endl;
}

{DIGIT}*(\.{DIGIT}+)\.[0-9\.Ee+-]*(\.)* {
	errorCount++;
	logOutput<<"Error at line# "<< lineCount <<": TOO_MANY_DECIMAL_POINTS "<<yytext<<endl;
}

({DIGIT}*(\.{DIGIT}*)?[Ee][+-]?[0-9\.Ee+-]*(\.)*)|({DIGIT}+\.) {
	errorCount++;
	logOutput<<"Error at line# "<< lineCount <<": ILLFORMED_NUMBER "<<yytext<<endl;
}

{DIGIT}+{ALPHA_NUMERIC}+ {
	errorCount++;
	logOutput<<"Error at line# "<< lineCount <<": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<endl;
}

\/\/(([^\\\r\n]|\\[^rn])*(\\[\r]?\n)*)*	{
	string temp=yytext;
	int lineCountAdd=countNewLines(temp);
	if(temp[temp.length()-1]=='\n')temp=temp.substr(0,temp.length()-2);
	logOutput<<"Line# "<< lineCount <<": Token <SINGLE LINE COMMENT> Lexeme "<<temp<<" found"<<endl;
	lineCount+=lineCountAdd;
}

\/\* {
	comment=yytext;
	BEGIN MULTI_COMMENT_STATE;
}

"+"|"-"	{
	tokenOutput<<"<ADDOP, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <ADDOP> Lexeme "<<yytext<<" found"<<endl;
}

"*"|"/"|"%"	{
	tokenOutput<<"<MULOP, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <MULOP> Lexeme "<<yytext<<" found"<<endl;
}

"++"|"--"	{
	tokenOutput<<"<INCOP, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <INCOP> Lexeme "<<yytext<<" found\n"<<endl;
}

"<"|"<="|">"|">="|"=="|"!="	{
	tokenOutput<<"<RELOP, "<<yytext<<">"<<endl;
	logOutput<<"Line#"<< lineCount <<": Token <RELOP> Lexeme "<<yytext<<" found\n"<<endl;
}

"="	{
	tokenOutput<<"<ASSIGNOP, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <ASSIGNOP> Lexeme "<<yytext<<" found"<<endl;
}

"&&"|"||"	{
	tokenOutput<<"<LOGICOP, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <LOGICOP> Lexeme "<<yytext<<" found"<<endl;
}

"!"	{
	tokenOutput<<"<NOT, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <NOT> Lexeme "<<yytext<<" found"<<endl;
}

"("	{
	tokenOutput<<"<LPAREN, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <LPAREN> Lexeme "<<yytext<<" found"<<endl;
}

")"	{
	tokenOutput<<"<RPAREN, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <RPAREN> Lexeme "<<yytext<<" found"<<endl;
}

"{"	{
	tokenOutput<<"<LCURL, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <LCURL> Lexeme "<<yytext<<" found"<<endl;
	symbolTable.enterScope();
}

"}"	{
	tokenOutput<<"<RCURL, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <RCURL> Lexeme "<<yytext<<" found"<<endl;
	symbolTable.exitScope();
}

"["	{
	tokenOutput<<"<LSQUARE, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <LSQUARE> Lexeme "<<yytext<<" found"<<endl;
}

"]"	{
	tokenOutput<<"<RSQUARE, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <RSQUARE> Lexeme "<<yytext<<" found"<<endl;
}

","	{
	tokenOutput<<"<COMMA, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <COMMA> Lexeme "<<yytext<<" found"<<endl;
}

";"	{
	tokenOutput<<"<SEMICOLON, "<<yytext<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <SEMICOLON> Lexeme "<<yytext<<" found"<<endl;
}

'(\\[nt\\'afrbv0]|[^\\'])'	{
	string temp=getPrintableString(yytext);
	tokenOutput<<"<CONST_CHAR, "<<temp.substr(1,temp.length()-2)<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <CONST_CHAR> Lexeme "<<temp.substr(1,temp.length()-2)<<" found"<<endl;
}

'(\\[nt\\'afrbv0]|[^\\\n'])+'	{
	errorCount++;
	logOutput<<"Error at line# "<< lineCount <<": MULTICHAR_CONST_CHAR "<<yytext<<endl;
}

'\\'|'[^'\n]*\n	{
	errorCount++;
	string temp=yytext;
	int addLineCount=0;
	if(temp[temp.length()-1]=='\n'){
		addLineCount=1;
		temp=temp.substr(0,temp.length()-2);
	}
	logOutput<<"Error at line# "<< lineCount <<": UNFINISHED_CONST_CHAR "<<temp<<endl;
	lineCount+=addLineCount;
}

'\\'|'[^'\n]*	{
	errorCount++;
	string temp=yytext;
	int addLineCount=0;
	logOutput<<"Error at line# "<< lineCount <<": UNFINISHED_CONST_CHAR "<<temp<<endl;
	lineCount+=addLineCount;
}

''	{
	errorCount++;
	logOutput<<"Error at line# "<< lineCount <<": EMPTY_CONST_CHAR "<<yytext<<endl;
}

\"([^\"\\\n]|\\[nt\\'afrbv0])*\"	{
	string temp=yytext;
	temp=getPrintableString(temp.substr(1,temp.length()-2));
	tokenOutput<<"<SINGLE LINE STRING, "<<temp<<">"<<endl;
	logOutput<<"Line# "<< lineCount <<": Token <SINGLE LINE STRING> Lexeme "<<yytext<<" found"<<endl;
}

\"(([^\"\\\r\n]|\\[nt\\'afrbv0])*(\\[\r]?\n)*)*\"	{
	string temp=yytext;
	logOutput<<"Line# "<< lineCount <<": Token <MULTI LINE STRING> Lexeme "<<yytext<<" found"<<endl;
	temp=getPrintableString(temp.substr(1,temp.length()-2));
	tokenOutput<<"<MULTI LINE STRING, "<<temp<<">"<<endl;
}

\"(([^\"\\\r\n]|\\[nt\\'afrbv0])*(\\[\r]?\n)*)*	{
	errorCount++;
	string temp=yytext;
	if(temp[temp.length()-1]=='\n')temp.pop_back();
	lineCount+=countNewLines(temp);
	//just to count the newlines in the string
	logOutput<<"Error at line# "<< lineCount <<": UNFINISHED_STRING "<<yytext<<endl;
}

<MULTI_COMMENT_STATE>\*\/	{
	comment+="*/";
	logOutput<<"Line# "<< lineCount-countNewLines(comment) <<": Token <MULTI LINE COMMENT> Lexeme "<<comment<<" found"<<endl;
	BEGIN INITIAL;
	}
<MULTI_COMMENT_STATE>\n	{
	comment+='\n';
	lineCount++;
}
<MULTI_COMMENT_STATE><<EOF>>	{
	errorCount++;
	logOutput<<"Error at line# "<< lineCount <<": UNFINISHED_COMMENT "<<comment<<endl;
	BEGIN INITIAL;
}
<MULTI_COMMENT_STATE>.	{
	comment+=yytext;
}

. {
	errorCount++;
	logOutput<<"Error at line# "<< lineCount <<": UNRECOGNIZED_CHAR "<<yytext<<endl;
}

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fileInput=fopen(argv[1],"r");
	if(fileInput==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

	tokenOutput.open("1905026_token.txt");
	logOutput.open("1905026_log.txt");

	yyin= fileInput;
	yylex();
	fclose(yyin);

	symbolTable.printAllScope(logOutput);

	logOutput<<"Total lines: "<<lineCount<<endl;
	logOutput<<"Total errors: "<<errorCount<<endl;

	tokenOutput.close();
	logOutput.close();


	return 0;
}