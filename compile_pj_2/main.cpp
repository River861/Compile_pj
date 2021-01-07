#include <iostream>
#include <cstdio>
#include <string>
#include <iomanip>
#include <cctype>
#include <vector>
#include <string>
using namespace std;
const int N = 14;

int yyparse();
int yyrestart(FILE *);
extern "C" FILE *yyin;
extern "C" FILE *yyout;
extern "C" int yydebug;
extern "C" int yylineno;

struct Node { // 语法树节点
    string name;
    vector<Node*> children;
};
extern "C" Node *root;

void print_subtree(Node* root, int offset, vector<string>& graph)
{
    string row = string(offset - 5, ' ') + "+--- " + root->name;
    graph.push_back(string(offset - 4, ' '));  // 使树看起来松散一点
    graph.push_back(row);
    for(Node* child : root->children)
    {
        print_subtree(child, offset + 5, graph);
    }
}

void print_tree(Node* root)
{
    if(root == nullptr) return;
    vector<string> graph;
    graph.push_back(root->name);
    for(Node* child : root->children)
    {
        print_subtree(child, 5, graph);
    }
    for(int i = 0; i < graph.size(); i ++)  // 补充完整树形图上的竖线
    {
        for(int j = 0; j < graph[i].size(); j ++) if(graph[i][j] == '+')
        {
            for(int k = i - 1; k >= 0 && j < graph[k].size() && graph[k][j] == ' '; k --) graph[k][j] = '|';
        }
    }
    for(const string& row : graph)  // 打印语法树
    {
        cout << row << endl;
    }
}

void solve(const string& case_num)
{
    yyin = fopen(("input/case_" + case_num + ".pcat").c_str(), "r");
    yyout = freopen(("output/case_" + case_num + ".txt").c_str(), "w", stdout);
    root = nullptr;
    yyrestart(yyin);
    yylineno = 1;
    yyparse();
    print_tree(root);
    fclose(yyin);
    fclose(yyout);
}

int main()
{
    yydebug = 0;
    for(int i = 1; i <= N; i ++) solve(to_string(i));
    // solve("13");
    return 0;
}
