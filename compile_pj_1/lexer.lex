%{
#include "lexer.h"
#include <cctype>

int row = 1, col = 1;
%}

%option nounput
%option noyywrap

NL      [\n]
WS      [ \t]+
LETTER  [A-Za-z]
DIGIT   [0-9]
ANY     [\s\S]

%%

{NL}               { row ++; col = 1; }
{WS}               { col += yyleng; }
<<EOF>>            { row = col = 1; return T_EOF; }

"AND"|"ARRAY"|"BEGIN"|"BY"|"DIV"|"DO"|"ELSE"|"ELSIF"|"END"|"EXIT"|"FOR" return RESERVED;
"IF"|"IN"|"IS"|"LOOP"|"MOD"|"NOT"|"OF"|"OR"|"OUT"|"PROCEDURE"|"PROGRAM" return RESERVED;
"READ"|"RECORD"|"RETURN"|"THEN"|"TO"|"TYPE"|"VAR"|"WHILE"|"WRITE" return RESERVED;

{DIGIT}+ {  // 整数
    if(yyleng > 10 || atoll(yytext) >= (1LL << 31)) return INT_OUT_OF_RANGE;
    return INTEGER; 
}

{DIGIT}+"."{DIGIT}* return REAL;  // 实数

"\""[^\"\n]*"\"" {  // 字符串
    if(yyleng - 2 > 255) return STR_OVER_LONG;
    for(int i = 0; i < yyleng; i ++) if(yytext[i] == '\t') return STR_WITH_TAB;
    return STRING;
}

{LETTER}({LETTER}|{DIGIT})* {  // 标识符
    if(yyleng > 255) return ID_OVER_LONG;
    return ID;
}

":="|"+"|"-"|"*"|"/"|"<"|"<="|">"|">="|"="|"<>" return OPERATOR;
":"|";"|","|"."|"("|")"|"["|"]"|"{"|"}"|"[<"|">]"|"\\" return DELIMITER;
"(*"([^\*]*|[^\)]*|({ANY}*\*{ANY}+\){ANY}*))"*)"   return COMMENT;

"\""[^\"\n]* return STR_UNTERMINATED;  // 未写完的字符串
"(*"([^\*]*|[^\)]*|({ANY}*\*{ANY}+\){ANY}*))   return COMMENT_UNTERMINATED;  // 未写完的注释

. {  // 其它字符
    if(!isprint(yytext[0])) return BAD_CHAR;
}

%%
