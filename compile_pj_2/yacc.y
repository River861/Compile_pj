%{
#include <iostream>
#define YYDEBUG 1
#include "lexer.c"
using namespace std;

Node* root;

void insert(Node* fa, Node* child)  // 添加一个孩子节点
{
    fa->children.push_back(child);
}

void insert(Node* fa, const vector<Node*>& children)  // 添加若干孩子节点
{
    for(Node* child : children) fa->children.push_back(child);
}

void insert(Node* fa, const string& str)  // 添加一个叶子节点
{
    fa->children.push_back(new Node(str));
}
%}

%union {
    struct Node *node;
}

%error-verbose

// 终结符
%token <node> TEST

%left  <node> ':' ';' ',' '.' '\\' ASSIGN
%left  <node> '<' '>' '=' LE GE NE
%left  <node> '+' '-' OR
%left  <node> '*' '/' MOD DIV AND 
%left  <node> NOT UNARY // 一元操作符
%token <node> '(' ')' '[' ']' '{' '}' LEFT_ARRAY RIGHT_ARRAY  // 括号

%token <node> ARRAY _BEGIN BY DO ELSE ELSIF END EXIT FOR IF IN IS LOOP OF
%token <node> OUT PROCEDURE PROGRAM READ RECORD RETURN THEN TO TYPE VAR WHILE WRITE
%token <node> INTEGER REAL STRING ID COMMENT

%token <node> INT_OUT_OF_RANGE STR_WITH_TAB STR_OVER_LONG STR_UNTERMINATED
%token <node> ID_OVER_LONG COMMENT_UNTERMINATED BAD_CHAR

// 非终结符
%type <node> program
%type <node> body
%type <node> some_declaration
%type <node> some_statement
%type <node> declaration
%type <node> some_var-decl
%type <node> some_type-decl
%type <node> some_procedure-decl
%type <node> var-decl
%type <node> some_ID
%type <node> type-decl
%type <node> procedure-decl
%type <node> type
%type <node> some_component
%type <node> component
%type <node> formal-params
%type <node> some_fp-section
%type <node> fp-section
%type <node> statement
%type <node> some_lvalue
%type <node> some_elsif
%type <node> elsif
%type <node> write-params
%type <node> some_write-expr
%type <node> write-expr
%type <node> expression
%type <node> lvalue
%type <node> actual-params
%type <node> some_expression
%type <node> comp-values
%type <node> some_assignment
%type <node> assignment
%type <node> array-values
%type <node> some_array-value
%type <node> array-value
%type <node> number
%type <node> unary-op
%type <node> binary-op

// 特殊测例
%type<node> some_test_case
%type<node> test_case

%%
program: PROGRAM IS body ';' {
        $$ = new Node("progarm");
        insert($$, $3);
        root = $$; // 储存语法树指针
    }
    | some_test_case {
        $$ = new Node("test_11");
        insert($$, $1);
        root = $$; // 储存语法树指针
    }
    ;

some_test_case: test_case {
        $$ = new Node("test_case_list");
        insert($$, $1);
    }
    | some_test_case test_case {
        $$ = new Node("test_case_list");
        insert($$, $1->children);
        insert($$, $2);
    }
    ;

test_case: number {
        $$ = new Node("test_case");
        insert($$, $1);
    }
    | INT_OUT_OF_RANGE {
        $$ = new Node("test_case");
        insert($$, $1);
    }
    | STRING {
        $$ = new Node("test_case");
        insert($$, $1);
    }
    | STR_WITH_TAB {
        $$ = new Node("test_case");
        insert($$, $1);
    }    
    | STR_OVER_LONG {
        $$ = new Node("test_case");
        insert($$, $1);
    }
    | ID {
        $$ = new Node("test_case");
        insert($$, $1);
    }
    | ID_OVER_LONG {
        $$ = new Node("test_case");
        insert($$, $1);
    }
    | statement {
        $$ = new Node("test_case");
        insert($$, $1);
    }
    | number ID {
        $$ = new Node("test_case");
        insert($$, vector<Node*>{$1, $2});
    }
    | BAD_CHAR {
        $$ = new Node("test_case");
        insert($$, $1);
    }
    | STR_UNTERMINATED {
        $$ = new Node("test_case");
        insert($$, $1);
    }
    | COMMENT {
        $$ = new Node("test_case");
        insert($$, $1);
    }
    | COMMENT_UNTERMINATED {
        $$ = new Node("test_case");
        insert($$, $1);
    }
    | COMMENT test_case {
        $$ = new Node("test_case");
        insert($$, $1);
        insert($$, $2->children);
    }
    ;

body: some_declaration _BEGIN some_statement END  { 
        $$ = new Node("body");
        insert($$, vector<Node*>{$1, $3});
    }
    ;

some_declaration: { // 叶子
        $$ = new Node("decl_list");
    }
    | some_declaration declaration {
        $$ = new Node("decl_list");
        insert($$, $1->children);
        insert($$, $2);
    }
    ;

some_statement: { // 叶子
        $$ = new Node("statement_list");
    }
    | some_statement statement {
        $$ = new Node("statement_list");
        insert($$, $1->children);
        insert($$, $2);
    }
    ;

declaration: VAR some_var-decl {
        $$ = $2;
    }
    | TYPE some_type-decl {
        $$ = $2;
    }
    | PROCEDURE some_procedure-decl {
        $$ = $2;
    }
    ;

some_var-decl: { // 叶子
        $$ = new Node("var_decl_list");
    }
    | some_var-decl var-decl {
        $$ = new Node("var_decl_list");
        insert($$, $1->children);
        insert($$, $2);
    }
    ;

some_type-decl: { // 叶子
        $$ = new Node("type_decl_list");
    }
    | some_type-decl type-decl {
        $$ = new Node("type_decl_list");
        insert($$, $1->children);
        insert($$, $2);
    }
    ;

some_procedure-decl: { // 叶子
        $$ = new Node("procedure_decl_list");
    }
    | some_procedure-decl procedure-decl {
        $$ = new Node("procedure_decl_list");
        insert($$, $1->children);
        insert($$, $2);
    }
    ;

var-decl: some_ID ':' type ASSIGN expression ';' {
        $$ = new Node("var_decl");
        insert($$, vector<Node*>{$1, $3, $5});
    }
    | some_ID ASSIGN expression ';' {
        $$ = new Node("var_decl");
        insert($$, vector<Node*>{$1, $3});
    }
    ;

some_ID: ID {
        $$ = new Node("ID_list");
        insert($$, $1);
    }
    | some_ID ',' ID {
        $$ = new Node("ID_list");
        insert($$, $1->children);
        insert($$, $3);
    }
    ;

type-decl: ID IS type ';' {
        $$ = new Node("type_decl");
        insert($$, vector<Node*>{$1, $3});
    }
    ;

procedure-decl: ID formal-params ':' type IS body ';' {
        $$ = new Node("procedure_decl");
        insert($$, vector<Node*>{$1, $2, $4, $6});
    }
    | ID formal-params IS body ';' {
        $$ = new Node("procedure_decl");
        insert($$, vector<Node*>{$1, $2, $4});
    }
    ;

type: ID {
        $$ = new Node("type");
        insert($$, $1);
    }
    | ARRAY OF type {
        $$ = new Node("array_type");
        insert($$, $1);
    }
    | RECORD some_component END {
        $$ = new Node("record_type");
        insert($$, $2->children);
    }
    ;

some_component: component { 
        $$ = new Node("component_list");
        insert($$, $1);
    }
    | some_component component {
        $$ = new Node("component_list");
        insert($$, $1->children);
        insert($$, $2);
    }
    ;

component: ID ':' type ';' {
        $$ = new Node("component");
        insert($$, vector<Node*>{$1, $3});
    }
    ;

formal-params: '(' some_fp-section ')' {
        $$ = new Node("formal_params");
        insert($$, $2->children);
    }
    | '(' ')' {  // 叶子
        $$ = new Node("formal_params");
    }
    ;

some_fp-section: fp-section {
        $$ = new Node("fp_section_list");
        insert($$, $1);
    }
    | some_fp-section ';' fp-section {
        $$ = new Node("fp_section_list");
        insert($$, $1->children);
        insert($$, $3);
    }
    ;

fp-section: some_ID ':' type {
        $$ = new Node("fp_section");
        insert($$, vector<Node*>{$1, $3});
    }
    ;

statement: lvalue ASSIGN expression ';' {
        $$ = new Node("statement");
        insert($$, vector<Node*>{$1, $3});
    }
    | ID actual-params ';' {
        $$ = new Node("statement");
        insert($$, vector<Node*>{$1, $2});
    }
    | READ '(' some_lvalue ')' ';' {
        $$ = new Node("statement");
        insert($$, $3->children);
    }
    | WRITE write-params ';' {
        $$ = new Node("statement");
        insert($$, $2);
    }
    | IF expression THEN some_statement some_elsif ELSE some_statement END ';' {
        $$ = new Node("statement");
        insert($$, $2);
        insert($$, $4->children);
        insert($$, $5->children);
        insert($$, $7->children);
    }
    | IF expression THEN some_statement some_elsif END ';' {
        $$ = new Node("decl_list");
        insert($$, $2);
        insert($$, $4->children);
        insert($$, $5->children);
    }
    | WHILE expression DO some_statement END ';' {
        $$ = new Node("statement");
        insert($$, $2);
        insert($$, $4->children);
    }
    | LOOP some_statement END ';' {
        $$ = new Node("statement");
        insert($$, $2->children);
    }
    | FOR ID ASSIGN expression TO expression BY expression DO some_statement END ';' {
        $$ = new Node("statement");
        insert($$, vector<Node*>{$2, $4, $6, $8});
        insert($$, $10->children);
    }
    | FOR ID ASSIGN expression TO expression DO some_statement END ';' {
        $$ = new Node("statement");
        insert($$, vector<Node*>{$2, $4, $6});
        insert($$, $8->children);
    }
    | EXIT ';' {  // 叶子
        $$ = new Node("exit_statement");
    }
    | RETURN expression ';'{
        $$ = new Node("return_statement");
        insert($$, $2);
    }
    | RETURN ';' {  // 叶子
        $$ = new Node("return_statement");
    }
    | statement COMMENT {
        $$ = new Node("statement");
        insert($$, vector<Node*>{$1, $2});
    }
    ;

some_lvalue: lvalue {
        $$ = new Node("lvalue");
        insert($$, $1);
    }
    | some_lvalue ',' lvalue {
        $$ = new Node("lvalue");
        insert($$, $1->children);
        insert($$, $3);
    }
    ;

some_elsif: { // 叶子
        $$ = new Node("elsif_list");
    }
    | some_elsif elsif {
        $$ = new Node("elsif_list");
        insert($$, $1->children);
        insert($$, $2);
    }
    ;

elsif: ELSIF expression THEN some_statement {
        $$ = new Node("elsif");
        insert($$, $2);
        insert($$, $4->children);
    }
    ;

write-params: '(' some_write-expr ')' {
        $$ = new Node("write_params");
        insert($$, $2->children);
    }
    | '(' ')' {  // 叶子
        $$ = new Node("write_params");
    }
    ;

some_write-expr: write-expr {
        $$ = new Node("write_expr_list");
        insert($$, $1);
    }
    | some_write-expr ',' write-expr {
        $$ = new Node("write_expr_list");
        insert($$, $1->children);
        insert($$, $3);
    }
    ;

write-expr: STRING {
        $$ = new Node("write_expr");
        insert($$, $1);
    }
    | expression {
        $$ = new Node("write_expr");
        insert($$, $1);
    }
    ;

expression: number {
        $$ = new Node("expression");
        insert($$, $1);
    }
    | lvalue {
        $$ = new Node("expression");
        insert($$, $1);
    }
    | '(' expression ')' {
        $$ = new Node("expression");
        insert($$, $2);
    }
    | unary-op expression %prec UNARY {
        $$ = new Node("expression");
        insert($$, vector<Node*>{$1, $2});
    }
    | expression binary-op expression {
        $$ = new Node("expression");
        insert($$, vector<Node*>{$1, $2, $3});
    }
    | ID actual-params {
        $$ = new Node("expression");
        insert($$, vector<Node*>{$1, $2});
    }
    | ID comp-values {
        $$ = new Node("expression");
        insert($$, vector<Node*>{$1, $2});
    }
    | ID array-values {
        $$ = new Node("expression");
        insert($$, vector<Node*>{$1, $2});
    }
    ;

lvalue: ID {
        $$ = new Node("lvalue");
        insert($$, $1);
    }
    | lvalue '[' expression ']' {
        $$ = new Node("lvalue");
        insert($$, vector<Node*>{$1, $3});
    }
    | lvalue '.' ID {
        $$ = new Node("lvalue");
        insert($$, vector<Node*>{$1, $3});
    }
    ;

actual-params: '(' some_expression ')' {
        $$ = new Node("actual_params");
        insert($$, $2->children);
    }
    | '(' ')' {  // 叶子
        $$ = new Node("actual_params");
    }
    ;

some_expression: expression {
        $$ = new Node("expression_list");
        insert($$, $1);
    }
    | some_expression ',' expression {
        $$ = new Node("expression_list");
        insert($$, $1->children);
        insert($$, $3);
    }
    ;

comp-values: '{' some_assignment '}' {
        $$ = new Node("comp-values");
        insert($$, $2->children);
    }
    ;

some_assignment: assignment {
        $$ = new Node("assignment_list");
        insert($$, $1);
    }
    | some_assignment ';' assignment {
        $$ = new Node("assignment_list");
        insert($$, $1->children);
        insert($$, $3);
    }
    ;

assignment: ID ASSIGN expression {
        $$ = new Node("assignment");
        insert($$, vector<Node*>{$1, $3});
    }
    ;

array-values: LEFT_ARRAY some_array-value RIGHT_ARRAY {
        $$ = $2;
    }
    ;

some_array-value: array-value {
        $$ = new Node("array_value_list");
        insert($$, $1);
    }
    | some_array-value ',' array-value {
        $$ = new Node("array_value_list");
        insert($$, $1->children);
        insert($$, $3);
    }
    ;

array-value: expression OF expression {
        $$ = new Node("array_value");
        insert($$, vector<Node*>{$1, $3});
    }
    | expression {
        $$ = new Node("array_value");
        insert($$, $1);
    }
    ;

number: INTEGER {
        $$ = new Node("number");
        insert($$, $1);
    }
    | REAL {
        $$ = new Node("number");
        insert($$, $1);
    }
    ;

unary-op: '+' {
        $$ = new Node("unary-op");
        insert($$, "+");
    }
    | '-' {
        $$ = new Node("unary-op");
        insert($$, "-");
    }
    | NOT {
        $$ = new Node("unary-op");
        insert($$, "NOT");
    }
    ;

binary-op: '+' {
        $$ = new Node("binary-op");
        insert($$, "+");
    }
    | '-' {
        $$ = new Node("binary-op");
        insert($$, "-");
    }
    | '*' {
        $$ = new Node("binary-op");
        insert($$, "*");
    }
    | '/' {
        $$ = new Node("binary-op");
        insert($$, "/");
    }
    | DIV {
        $$ = new Node("binary-op");
        insert($$, "DIV");
    }
    | MOD {
        $$ = new Node("binary-op");
        insert($$, "MOD");
    }
    | OR {
        $$ = new Node("binary-op");
        insert($$, "OR");
    }
    | AND {
        $$ = new Node("binary-op");
        insert($$, "AND");
    }
    | '>' {
        $$ = new Node("binary-op");
        insert($$, ">");
    }
    | '<' {
        $$ = new Node("binary-op");
        insert($$, "<");
    }
    | '=' {
        $$ = new Node("binary-op");
        insert($$, "=");
    }
    | GE {
        $$ = new Node("binary-op");
        insert($$, ">=");
    }
    | LE {
        $$ = new Node("binary-op");
        insert($$, "<=");
    }
    | NE {
        $$ = new Node("binary-op");
        insert($$, "<>");
    }
    ;

%%
