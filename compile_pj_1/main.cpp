#include <iostream>
#include <cstdio>
#include <string>
#include <iomanip>
#include "lexer.h"
#include <cctype>
using namespace std;
const int N = 11;

int yylex();
extern "C" FILE *yyin;
extern "C" FILE *yyout;
extern "C" char *yytext;
extern "C" int  yyleng;
extern "C" int row, col;

const string TYPE_NAMES[8] =
{
    // 标识类型名
    "reserved keyword", "integer", "real",
    "string", "identifier", "operator", "delimiter",
    "comment"
};

const string ERROR_MSG[7] =
{
    // 错误信息
    "out of range integer", "invalid string with tab in it", "overly long string",
    "overly long identifier", "bad character", "unterminated string",
    "unterminated comment"
};

void update_pos(int type)
{
    // 更新当前扫描到的位置信息(row, col)
    if(type == COMMENT)
    {
        for(int i = 0; i < yyleng; i ++)
        {
            if(yytext[i] == '\n') row ++, col = 1;
            else col ++;
        }
    }
    else col += yyleng;
}

void solve()
{
    // 扫描一个yyin所指的文件，输出到yyout中
    cout << left << setw(4) << "ROW" << setw(4) << "COL"
         << setw(20) << "TYPE" << "TOKEN/ERROR MESSAGE" << endl;
    
    int type;
    while ((type = yylex()) != T_EOF)
    {
        if(type > 0)
        {
            cout << setw(4) << row << setw(4) << col
                 << setw(20) << TYPE_NAMES[type - 1] << yytext << endl;
        }
        else
        {
            cout << setw(4) << row << setw(4) << col
                 << setw(20) << "-" << ERROR_MSG[-1 - type] << endl;
        }
        update_pos(type);
    }
}


int main()
{
    // N个测试用例
    for(int i = 1; i <= N; i ++)
    {
        yyin = fopen(("input/case_" + to_string(i) + ".pcat").c_str(), "r");
        yyout = freopen(("output/case_" + to_string(i) + ".txt").c_str(), "w", stdout);
        solve();
        fclose(yyin);
        fclose(yyout);
    }
    return 0;
}