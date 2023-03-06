%{
    #include <stdio.h>
    extern FILE* yyin;
%}

%define parse.error verbose
%start prog_start
%token PLUS MINUS MULT MOD DIV EQUALS LESSTHAN GREATERTHAN ISEQUAL ISNOTEQUAL GTEQUAL LTEQUAL NOT SEMICOLON L_PAREN R_PAREN L_CURLY R_CURLY L_BRACKET R_BRACKET COMMA DECIMAL READ WRITE IF IFELSE ELSE WHILELOOP INTEGER NUMBER FUNCTION RETURN IDENTIFIER

%%

prog_start: %empty /* epsilon */ {printf("prog_start -> epsilon\n");}
    | functions {printf("prog_start -> functions\n");}
    ;

functions: function {printf("functions -> function\n");}
    | function functions {printf("functions -> function functions\n");}
    ;

function: FUNCTION IDENTIFIER L_PAREN arguments R_PAREN L_CURLY statements R_CURLY {printf("function -> FUNCTION IDENTIFIER L_PAREN arguments R_PAREN L_CURLY statements R_CURLY\n");}
    ;

arguments: argument {printf("arguments -> argument\n");}
    | argument COMMA arguments {printf("arguments -> argument COMMA arguments\n");}
    ;

argument: %empty /* epsilon */ {printf("argument -> epsilon\n");}
    | INTEGER IDENTIFIER {printf("argument -> INTEGER IDENTIFIER\n");}
    ;

statements: %empty {printf("statements -> epsilon\n");}
    | statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
    | statement_p statements {printf("statements -> statement_p statements\n");}
    ;

statement_p : s_if {printf("statement_p -> s_if\n");}
    | s_while {printf("statement_p -> s_while\n");}
    ;

statement: declaration {printf("statement -> declaration\n");}
    | s_var {printf("statment -> s_var\n");}
    | READ L_PAREN var R_PAREN {printf("statement -> READ L_PAREN var R_PAREN\n");}
    | WRITE L_PAREN expression R_PAREN {printf("statement -> WRITE L_PAREN var R_PAREN\n");}
    | RETURN expression {printf("statement -> RETURN expression\n");}
    ;

s_var: var EQUALS expression {printf("s_var -> var EQUALS expression\n");}
    ;

s_if: IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY {printf("s_if -> IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY\n");}
    | IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY IFELSE neg L_CURLY statements R_CURLY {printf("IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY IFELSE neg L_CURLY statements R_CURLY\n");}
    | IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY ELSE L_CURLY statements R_CURLY {printf("s_if -> IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY ELSE L_CURLY statements R_CURLY\n");}
    ;

s_while: WHILELOOP L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY {printf("s_while -> WHILELOOP L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY\n");}
    ;

expression: expression addop term {printf("expression -> expression addop term\n");}
    | term {printf("expression -> term\n");}
    ;

addop: PLUS {printf("addop -> PLUS\n");}
    | MINUS {printf("term -> MINUS\n");}
    ;

term: term mulop factor {printf("term -> term MULOP factor\n");}
    | factor {printf("term -> factor\n");}
    ;

mulop: MULT {printf("mulop -> MULT\n");}
    | DIV {printf("mulop -> DIV\n");}
    | MOD {printf("mulop -> MOD\n");}
    ;

factor: func L_PAREN expression R_PAREN {printf("factor -> func L_PAREN expression R_PAREN\n");}
    | NUMBER {printf("factor -> NUMBER\n");}
    | var {printf("factor -> var\n");}
    | NUMBER DECIMAL NUMBER {printf("factor -> NUMBER DECIMAL NUMBER\n");}
    ;

func: %empty {printf("func -> epsiolon\n");}
    | IDENTIFIER {printf("func -> IDENTIFIER\n");}
    ;

expression_bool: expression_bool ne_comp term_bool{printf("expression_bool -> expression_bool ne_op term_bool\n");}
    | term_bool {printf("expression_bool -> term_bool\n");}
    ;

ne_comp: ISNOTEQUAL {printf("ne_bool -> ISNOTEQUAL\n");}
    | LESSTHAN {printf("ne_bool -> LESSTHAN\n");}
    | GREATERTHAN {printf("ne_bool -> GREATERTHAN\n");}
    ;

term_bool: term_bool e_comp factor_bool {printf("term_bool -> term_bool e_comp factor_bool\n");}
    | factor {printf("term_bool -> factor_bool\n");}
    ;

e_comp: ISEQUAL {printf("e_comp -> ISEQUAL\n");}
    | LTEQUAL {printf("e_comp -> LTEQUAL\n");}
    | GTEQUAL {printf("e_comp -> GTEQUAL\n");}
    ;

factor_bool: L_PAREN expression R_PAREN {printf("factor_bool -> L_PAREN expression R_PAREN\n");}
    | NUMBER {printf("factor_bool -> NUMBER\n");}
    | var {printf("factor_bool -> var\n");}
    ;

var: IDENTIFIER {printf("var -> IDENTIFIER\n");}
    | IDENTIFIER L_BRACKET NUMBER R_BRACKET {printf("var -> IDENTIFIER L_BRACKET NUMBER R_BRACKET\n");}
    ;

neg: 
        NOT {printf("neg -> NOT\n");}
        | %empty /* epsilon */ {printf("neg -> epsilon\n");}
		;

declaration: INTEGER IDENTIFIER {printf("declaration -> INTEGER IDENTIFIER\n");}
    | INTEGER IDENTIFIER L_BRACKET expression R_BRACKET SEMICOLON{printf("array -> L_BRACKET arr_dec R_BRACKET SEMICOLON\n");}
    ;

// arr_dec: expression {printf("arr_dec -> expression");}
//    ;

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
int yyerror(char * string){
    printf("%s\n", string);
}
