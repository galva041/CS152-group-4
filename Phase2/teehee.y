%{
    #include <stdio.h>
    extern FILE* yyin;
%}

%start prog_start
%token PLUS MINUS MULT MOD DIV EQUALS LESSTHAN GREATERTHAN ISEQUAL ISNOTEQUAL GTEQUAL LTEQUAL NOT SEMICOLON L_PAREN R_PAREN L_CURLY R_CURLY L_BRACKET R_BRACKET COMMA DECIMAL READ WRITE IF IFELSE ELSE WHILELOOP INTEGER NUMBER FUNCTION RETURN IDENTIFIER

%%

prog_start: %empty /* epsilon */ {printf("prog_start -> epsilon\n");}
    | functions {printf("prog_start -> functions\n");}
    ;

functions: function {printf("functions -> function\n");}
    | function functions {printf("functions -> function functions\n");}
    ;

function: FUNCTION IDENTIFIER L_PAREN arguments R_PAREN L_CURLY statements R_CURLY {printf("function -> INT IDENTIFIER L_PAREN arguments R_PAREN L_CURLY statements R_CURLY\n");}
    ;

arguments: argument {printf("arguments -> argument\n");}
    | argument COMMA arguments {printf("arguments -> argument COMMA arguments\n");}
    ;

argument: %empty /* epsilon */ {printf("argument -> epsilon\n");}
    | IDENTIFIER {printf("argument -> IDENTIFIER\n");}
    ;

statements: declaration {printf("statements -> declaration\n");}
    | statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
    ;

statement: s_var {printf("statement -> s_var\n");}
    | s_if {printf("statement -> s_if\n");}
    | s_while {printf("statement -> s_while\n");}
    | READ L_PAREN var R_PAREN {printf("statement -> read\n");}
    | WRITE L_PAREN var R_PAREN {printf("statement -> write\n");}
    | RETURN expression {printf("statement -> RETURN\n");}
    ;

s_var: var EQUALS expression {printf("statement -> var EQUALS expression");}
    ;

s_if: IF bool_exp L_CURLY statement R_CURLY {printf("s_if -> IF bool_exp L_CURLY statement R_CURLY\n");}
    | IF bool_exp L_CURLY statement R_CURLY IFELSE bool_exp L_CURLY statement R_CURLY {printf("IF bool_exp L_CURLY statement R_CURLY IFELSE bool_exp L_CURLY statement R_CURLY\n");}
    | IF bool_exp L_CURLY statement R_CURLY ELSE L_CURLY statement R_CURLY {printf("s_if -> IF bool_exp L_CURLY statement R_CURLY ELSE L_CURLY statement R_CURLY\n");}
    ;

s_while: WHILELOOP bool_exp L_CURLY statement R_CURLY {printf("WHILELOOP bool_exp L_CURLY statement R_CURLY");}
    ;

// read: READ L_PAREN var R_PAREN {printf("read -> READ L_PAREN var R_PAREN ");}
//     ;
// write: WRITE L_PAREN var R_PAREN {printf("write -> WRITE L_PAREN var R_PAREN ");}
//     ;

expression: mulop {printf("expression -> mulop\n");}
    | mulop PLUS mulop {printf("expression -> mulop ADD mulop\n");}
    | mulop MINUS mulop {printf("expression -> mulop MINUS mulop\n");}
    ;

mulop: term {printf("mulop -> term");}
    | term MULT term {printf("mulop -> term MULT term\n");}
    | term DIV term {printf("mulop -> term DIV term\n");}
    | term MOD term {printf("mulop -> term MOD term\n");}
    ;

term: var {printf("term -> var\n");}
    | INTEGER {printf("term -> INTEGER\n");}
    | L_PAREN expression R_PAREN {printf("term -> L_PAREN expression R_PAREN\n");}
    | IDENTIFIER L_PAREN expression expression_loop R_PAREN {printf("term -> IDENTIFIER L_PAREN expression expression_loop R_PAREN \n");}
    | INTEGER DECIMAL INTEGER {printf("term -> INTEGER DECIMAL INTEGER\n");}
    ;

expression_loop: %empty /*epsilon*/ {printf("expression_loop -> epsilon\n");}
    | COMMA expression expression_loop {printf("expression_loop -> COMMA expression expression_loop\n");}
    ;

var: IDENTIFIER {printf("var -> IDENTIFIER\n");}
    | IDENTIFIER L_BRACKET expression R_BRACKET {printf("var -> IDENTIFIER L_BRACKET expression R_BRACKET \n");}
    ;

bool_exp: 
        bool_exp_p expression comp expression {printf("bool_exp->expression comp expression\n");}
		;
bool_exp_p: 
        NOT {printf("bool_exp_p->NOT\n");}
        | %empty /* epsilon */ {printf("bool_exp_p -> epsilon\n");}
		;

comp: 
    ISEQUAL {printf("comparison->EQUAL\n");}
    | ISNOTEQUAL {printf("comparison->NOT EQUAL\n");}
    | LESSTHAN {printf("comparison->LESS THAN\n");}
    | GREATERTHAN {printf("comparison->GREATER THAN\n");}
    | LTEQUAL {printf("comparison->LESS THAN OR EQUAL\n");}
    | GTEQUAL {printf("comparison->GREATER THAN OR EQUAL\n");}
    ;

declaration: INTEGER IDENTIFIER {printf("declaration -> INTEGER IDENTIFIER\n");}
    | INTEGER IDENTIFIER L_BRACKET arr_dec R_BRACKET {printf("array -> L_BRACKET arr_dec R_BRACKET\n");}
    ;

arr_dec: NUMBER {printf("arr_dec -> INTEGER\n");}
    | expression {printf("arr_dec -> expression");}
    ;

// function_call: IDENTIFIER L_PAREN args R_PAREN {printf("function_call -> IDENTIFIER L_PAREN args R_PAREN\n");}
//     ;

// args: %empty {printf("args -> epsilon\n");} 
//     ;

%%

void main(int argc, char** argv) {
    if (argc >= 2) {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL) 
            yyin = stdin;
    }
    else {
        yyin = stdin;
    }
    yyparse();
}
int yyerror(){}
