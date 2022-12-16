%option noyywrap

%x CHAR_STATE
%x STR_STATE
%x SINGLE_COMMENT_STATE
%x MULTI_COMMENT_STATE

%{

#include<bits/stdc++.h>

#include "SymbolTable.h"

using namespace std;

int line_count = 1;
int error_count = 0;
int nl_inside = 0;

ofstream logOutput;
ofstream tokenOutput;

string resultString;
string resultPlainTextString;

string resultChar;
string resultPlainTextChar;

string commentString;

char res_ch;

int bucketSize = 10;
SymbolTable symbolTable(bucket_size);

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z_]
DIGIT [0-9]
NEWLINE [\r]?\n
KEYWORDS if|else|for|while|do|break|int|char|float|double|void|return|switch|case|default|continue
ALPHA_NUMERIC [A-Za-z_0-9]
/* ALL_EXCEPT_BACKSLASH [^\\] */

%%

{WHITESPACE} {}

{NEWLINE} {line_count++;}

{KEYWORDS}	{
				string token = "";
				for(char ch:yytext)token+=toupper(ch);
				tokenOutput<<"<"<<token<<", "<<yytext<<"> "<<endl;
				logOutput<<"Line# "<<line_count<<": Token <"<<token<<"> Lexeme "<<yytext<<" found"<<endl;
			}

{DIGIT}+	{
				tokenOutput<<"<CONST_INT,"<<yytext<<"> ";
				logOutput<<"Line# "<<line_count<<": Token <CONST_INT> Lexeme "<<yytext<<" found"<<endl;	
			}

{DIGIT}*(\.{DIGIT}+)?([Ee][+-]?{DIGIT}+)?	{
				tokenOutput<<"<CONST_FLOAT,"<<yytext<<"> ";
				logOutput<<"Line no "<< line_count <<": Token <CONST_FLOAT> Lexeme "<<yytext<<" found"<<endl;
			}

{DIGIT}*(\.{DIGIT}+)\.[0-9\.Ee+-]*(\.)* {
	error_count++;
	logOutput<<"Error at line no "<< line_count <<": Too many decimal points "<<yytext<<"\n"<<endl;
}

([0-9]*(\.[0-9]*)?[Ee][+-]?[0-9]*[0-9\.Ee+-]*(\.)*)|([0-9]+\.) {
	error_count++;
	logOutput<<"Error at line no "<< line_count <<": Ill formed number "<<yytext<<"\n"<<endl;
}

{LETTER}{ALPHA_NUMERIC}*	{
		tokenOutput<<"<ID,"<<yytext<<"> ";
		logOutput<<"Line# "<< line_count <<": Token " <<"<ID>"<<" Lexeme "<<yytext<<" found\n"<<endl;
		
		if(symbolTable.insertSymbol(SymbolInfo(yytext,"ID"),logOutput))
		{
			symbolTable.printAllScope(logOutput);
		}
}

{DIGIT}*(\.{DIGIT}+)?(E[+-]?{DIGIT}+)?{LETTER}{ALPHA_NUMERIC}* {
	error_count++;
	logOutput<<"Error at line no "<< line_count <<": Invalid prefix on ID or invalid suffix on Number "<<yytext<<"\n"<<endl;
}

"+"|"-"	{
		tokenOutput<<"<ADDOP,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<ADDOP>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}

"*"|"/"|"%"	{
		tokenOutput<<"<MULOP,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<MULOP>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}

"++"|"--"	{
		tokenOutput<<"<INCOP,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<INCOP>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}

"<"|"<="|">"|">="|"=="|"!="	{
		tokenOutput<<"<RELOP,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<RELOP>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}

"="	{
		tokenOutput<<"<ASSIGNOP,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<ASSIGNOP>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}

"&&"|"||"	{
		tokenOutput<<"<LOGICOP,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<LOGICOP>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}

"!"	{
		tokenOutput<<"<NOT,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<NOT>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}

"("	{
		tokenOutput<<"<LPAREN,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<LPAREN>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}

")"	{
		tokenOutput<<"<RPAREN,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<RPAREN>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}

"{"	{
		tokenOutput<<"<LCURL,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<LCURL>"<<" Lexeme "<<yytext<<" found\n"<<endl;

		symbolTable.enter_scope();
}

"}"	{
		tokenOutput<<"<RCURL,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<RCURL>"<<" Lexeme "<<yytext<<" found\n"<<endl;

		symbolTable.exit_scope();
}

"["	{
		tokenOutput<<"<LTHIRD,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<LTHIRD>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}

"]"	{
		tokenOutput<<"<RTHIRD,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<RTHIRD>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}

","	{
		tokenOutput<<"<COMMA,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<COMMA>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}

";"	{
		tokenOutput<<"<SEMICOLON,"<<yytext<<"> ";
		logOutput<<"Line no "<< line_count <<": Token " <<"<SEMICOLON>"<<" Lexeme "<<yytext<<" found\n"<<endl;
}

\'	{
	ans_char.clear();
	ans_char_plain.clear();
	BEGIN CHAR_STATE;
	// logOutput<<"CHAR_STATE started"<<endl;
}


\"	{
	res.clear();
	res_plain.clear();

	nl_inside = 0;

	BEGIN STR_STATE;
	// logOutput<<"STR_STATE started"<<endl;
}	

\/\/	{
	comment.clear();
	comment += "//";

	nl_inside = 0;

	BEGIN SINGLE_COMMENT_STATE;
	// logOutput<<"SINGLE_COMMENT_STATE started"<<endl;
}	

\/\*	{
	comment.clear();
	comment += "/*";

	nl_inside = 0;

	BEGIN MULTI_COMMENT_STATE;
	// logOutput<<"MULTI_COMMENT_STATE started"<<endl;
}	

<CHAR_STATE>\\\\         ans_char += "\\", ans_char_plain +="\\\\";
<CHAR_STATE>\\\'         ans_char += "\'", ans_char_plain +="\\\'";
<CHAR_STATE>\\\"         ans_char += "\"", ans_char_plain +="\\\"";
<CHAR_STATE>\\a			 ans_char += "\a", ans_char_plain +="\\a";
<CHAR_STATE>\\b          ans_char += "\b", ans_char_plain +="\\b";
<CHAR_STATE>\\f          ans_char += "\f", ans_char_plain +="\\f";
<CHAR_STATE>\\n          ans_char += "\n", ans_char_plain +="\\n";
<CHAR_STATE>\\r          ans_char += "\r", ans_char_plain +="\\r";
<CHAR_STATE>\\t          ans_char += "\t", ans_char_plain +="\\t";
<CHAR_STATE>\\v          ans_char += "\v", ans_char_plain +="\\v";
<CHAR_STATE>\\0			 ans_char += "\0", ans_char_plain +="\\0";


<CHAR_STATE><<EOF>> {
	string for_print = "'"; 
	for_print += ans_char_plain;

	error_count++;
	logOutput<<"Error at line no "<< line_count <<": Unterminated character "<<for_print<<"\n"<<endl;

	BEGIN INITIAL;
}

<CHAR_STATE>\'	{

	string for_print = "'"; 
	for_print += ans_char_plain;
	for_print += "'";

	if((int)ans_char.size()==0)
	{
		if(ans_char_plain=="\\0")
		{
			tokenOutput<<"<CHAR_CONST,"<<ans_char<<"> ";
			logOutput<<"Line no "<< line_count <<": Token " <<"<CONST_CHAR>"<<" Lexeme "<<for_print<<" found --> <CHAR_CONST,"<<ans_char<<">\n"<<endl;

			if(symbolTable.insertSymbol(SymbolInfo(for_print,"CONST_CHAR"),logOutput))
			{
				symbolTable.printAllScope(logOutput);
			}
		}
		else
		{
			error_count++;
			logOutput<<"Error at line no "<< line_count <<": Empty character constant error "<<for_print<<"\n"<<endl;
		}
	}
	else if((int)ans_char.size()==1)
	{
			tokenOutput<<"<CHAR_CONST,"<<ans_char<<"> ";
			logOutput<<"Line no "<< line_count <<": Token " <<"<CONST_CHAR>"<<" Lexeme "<<for_print<<" found --> <CHAR_CONST,"<<ans_char<<">\n"<<endl;

			if(symbolTable.insertSymbol(SymbolInfo(for_print,"CONST_CHAR"),logOutput))
			{
				symbolTable.printAllScope(logOutput);
			}
	}
	else
	{
			error_count++;
			logOutput<<"Error at line no "<< line_count <<": Multi character constant error "<<for_print<<"\n"<<endl;
			BEGIN INITIAL;
	}

	BEGIN INITIAL;
}

<CHAR_STATE>[\r]?\n {

	string for_print = "'"; 
	for_print += ans_char_plain;

	error_count++;
	logOutput<<"Error at line no "<< line_count <<": Unterminated character "<<for_print<<"\n"<<endl;

	line_count++;
	BEGIN INITIAL;
}

<CHAR_STATE>.		ans_char += yytext[0] , ans_char_plain += yytext[0];


<STR_STATE>\\\\         res += "\\", res_plain +="\\\\";
<STR_STATE>\\\'         res += "\'", res_plain +="\\\'";
<STR_STATE>\\\"         res += "\"", res_plain +="\\\"";
<STR_STATE>\\a			res += "\a", res_plain +="\\a";
<STR_STATE>\\b          res += "\b", res_plain +="\\b";
<STR_STATE>\\f          res += "\f", res_plain +="\\f";
<STR_STATE>\\n          res += "\n", res_plain +="\\n";
<STR_STATE>\\r          res += "\r", res_plain +="\\r";
<STR_STATE>\\t          res += "\t", res_plain +="\\t";
<STR_STATE>\\v          res += "\v", res_plain +="\\v";
<STR_STATE>\\0         	res += "\0", res_plain +="\\0";

<STR_STATE>\\\r\n         { 
	nl_inside++;
	res_plain += "\\\r\n" ;
	// logOutput<<"OK ESCAPE"<<endl; 
	}
<STR_STATE>\\\n         { 
	nl_inside++;
	res_plain += "\\\n" ;
	// logOutput<<"OK ESCAPE"<<endl; 
	}
<STR_STATE>[\r]?\n { 
		nl_inside++;
		error_count++;
		logOutput<<"Error at line no "<< line_count <<": Unterminated String \""<<res_plain<<"\n"<<endl;

		line_count += nl_inside;
		nl_inside = 0;

		BEGIN(INITIAL);
	}
<STR_STATE><<EOF>>      { 
		error_count++;
		logOutput<<"Error at line no "<< line_count <<": Unterminated String \""<<res_plain<<"\n"<<endl;

		line_count += nl_inside;
		nl_inside = 0;
		 
		BEGIN(INITIAL);
	}

<STR_STATE>\"           {
							string for_print = "\"";
							for_print += res_plain;
							for_print += "\"";
							
							tokenOutput<<"<STRING,"<<"\""<<res<<"\"> ";
                         	logOutput<<"Line no "<< line_count <<": Token " <<"<STRING>"<<" Lexeme "<<for_print<<" found --> <STRING,\""<<res<<"\">\n"<<endl;
                         	
							line_count += nl_inside;
							nl_inside = 0;
							 
							BEGIN(INITIAL);
                     	}

<STR_STATE>.            {res += yytext[0]; res_plain+= yytext[0];}

<SINGLE_COMMENT_STATE>\\\r\n         { 
	nl_inside++;
	comment += "\\\r\n";
	// logOutput<<"OK ESCAPE SINGLE COMMENT"<<endl; 
	}

<SINGLE_COMMENT_STATE>\\\n         { 
	nl_inside++;
	comment += "\\\n";
	// logOutput<<"OK ESCAPE SINGLE COMMENT"<<endl; 
	}

<SINGLE_COMMENT_STATE>[\r]?\n           { 
		
		// logOutput<<"SINGLE COMMENT FINISHED "<<comment<<endl; 
		nl_inside++;
		logOutput<<"Line no "<< line_count <<": Token " <<"<COMMENT>"<<" Lexeme "<<comment<<" found\n"<<endl;
		
		line_count += nl_inside;
		nl_inside = 0;
		
		BEGIN(INITIAL);
	}
<SINGLE_COMMENT_STATE><<EOF>>      { 

		// logOutput<<"SINGLE COMMENT FINISHED "<<comment<<endl; 
		logOutput<<"Line no "<< line_count <<": Token " <<"<COMMENT>"<<" Lexeme "<<comment<<" found\n"<<endl;

		line_count += nl_inside;
		nl_inside = 0;
		
		BEGIN(INITIAL);
	}

<SINGLE_COMMENT_STATE>\\           { comment += "\\";}
<SINGLE_COMMENT_STATE>.            { comment += yytext[0];} 


<MULTI_COMMENT_STATE>\*\/       { 
		//logOutput<<"DOUBLE COMMENT FINISHED "<<comment<<endl; 
		comment += "*/";
		logOutput<<"Line no "<< line_count <<": Token " <<"<COMMENT>"<<" Lexeme "<<comment<<" found\n"<<endl;
		
		line_count += nl_inside;
		nl_inside = 0;
		
		BEGIN(INITIAL);
	}

<MULTI_COMMENT_STATE><<EOF>>       { 

		error_count++;
		logOutput<<"Error at line no "<< line_count <<": Unterminated Comment "<<comment<<"\n"<<endl;
		
		line_count += nl_inside;
		nl_inside = 0;
		
		BEGIN(INITIAL);
	}

<MULTI_COMMENT_STATE>\r            { comment += "\r";} 
<MULTI_COMMENT_STATE>\n            { nl_inside++; comment += "\n";} 
<MULTI_COMMENT_STATE>.            { comment += yytext[0];} 

. {
	error_count++;
	logOutput<<"Error at line no "<< line_count <<": Unrecognized character "<<yytext<<"\n"<<endl;
}

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

	tokenOutput.open("1705010_token.txt");
	logOutput.open("1705010_log.txt");

	yyin= fin;
	yylex();
	fclose(yyin);

	symbolTable.printAllScope(logOutput);

	logOutput<<"Total lines: "<<line_count<<endl;
	logOutput<<"Total errors: "<<error_count<<endl;

	tokenOutput.close();
	logOutput.close();


	return 0;
}