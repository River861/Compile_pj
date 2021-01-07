%{
#include "yacc.h"
#include <cctype>
#include <string>
#include <vector>
using namespace std;

struct Node { // 语法树节点
    string name;
    vector<Node*> children;
    Node() {}
    Node(const char* name) : name(name) {}
    Node(const string& name): name(name) {}
};

void yyerror(const char* msg)
{
    cout << "line " << yylineno << ": " << msg << endl;
}

%}

%option nounput
%option noyywrap
%option yylineno

NL      [\n]
WS      [ \t]+
LETTER  [A-Za-z]
DIGIT   [0-9]
ANY     [\s\S]

%%

{NL}               /* skip */
{WS}               /* skip */
<<EOF>>            yyterminate();  // 结束

"AND"              return AND;
"ARRAY"            return ARRAY;
"BEGIN"            return _BEGIN;
"BY"               return BY;
"DIV"              return DIV;
"DO"               return DO;
"ELSE"             return ELSE;
"ELSIF"            return ELSIF;
"END"              return END;
"EXIT"             return EXIT;
"FOR"              return FOR;
"IF"               return IF;
"IN"               return IN;
"IS"               return IS;
"LOOP"             return LOOP;
"MOD"              return MOD;
"NOT"              return NOT;
"OF"               return OF;
"OR"               return OR;
"OUT"              return OUT;
"PROCEDURE"        return PROCEDURE;
"PROGRAM"          return PROGRAM;
"READ"             return READ;
"RECORD"           return RECORD;
"RETURN"           return RETURN;
"THEN"             return THEN;
"TO"               return TO;
"TYPE"             return TYPE;
"VAR"              return VAR;
"WHILE"            return WHILE;
"WRITE"            return WRITE;

{DIGIT}+ {  // 整数
    yylval.node = new Node(yytext);
    if(yyleng > 10 || atoll(yytext) >= (1LL << 31)) {
        yyerror("integer out of range.");
        return INT_OUT_OF_RANGE;
    }
    return INTEGER; 
}

{DIGIT}+"."{DIGIT}* {  // 实数
    yylval.node = new Node(yytext);
    return REAL;
}

"\""[^\"\n]*"\"" {  // 字符串
    yylval.node = new Node(yytext);
    if(yyleng - 2 > 255) {
        yyerror("string over long.");
        return STR_OVER_LONG;
    }
    for(int i = 0; i < yyleng; i ++) if(yytext[i] == '\t') {
        yyerror("string with tab.");
        return STR_WITH_TAB;
    }
    return STRING;
}

"\""[^\"\n]* {
    yylval.node = new Node(yytext);  // 未写完的字符串
    yyerror("unterminated string.");
    return STR_UNTERMINATED;
}

{LETTER}({LETTER}|{DIGIT})* {  // 标识符
    yylval.node = new Node(yytext);
    if(yyleng > 255) {
        yyerror("id over long.");
        return ID_OVER_LONG;
    }
    return ID;
}

"+"|"-"|"*"|"/"|"<"|">"|"="|":"|";"|","|"."|"("|")"|"["|"]"|"{"|"}"|"\\" return yytext[0];

":="                return ASSIGN;
"<="                return LE;
">="                return GE;
"<>"                return NE;
"[<"                return LEFT_ARRAY;
">]"                return RIGHT_ARRAY;

"(*"([^\*]*|[^\)]*|({ANY}*\*{ANY}+\){ANY}*))"*)" {  // 注释
    yylval.node = new Node(yytext);
    return COMMENT;
}
"(*"([^\*]*|[^\)]*|({ANY}*\*{ANY}+\){ANY}*)) {  // 未写完的注释
    yylval.node = new Node(yytext);
    yyerror("unterminated comment.");
    return COMMENT_UNTERMINATED;
}

. {  // 其它字符
    if(!isprint(yytext[0])) {
        yylval.node = new Node("[Bad Char]");
        yyerror("bad char.");
        return BAD_CHAR;
    }
}

%%
