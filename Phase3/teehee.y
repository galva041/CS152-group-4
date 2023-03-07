%{
    #include <stdio.h>
    #include "y.tab.h"
    extern FILE* yyin;
    int lineCount = 1;
    int posCount = 1;
%}

%define parse.error verbose
%start prog_start
%token PLUS MINUS MULT MOD DIV EQUALS LESSTHAN GREATERTHAN ISEQUAL ISNOTEQUAL GTEQUAL LTEQUAL NOT SEMICOLON L_PAREN R_PAREN L_CURLY R_CURLY L_BRACKET R_BRACKET COMMA DECIMAL READ WRITE IF IFELSE ELSE WHILELOOP INTEGER NUMBER FUNCTION RETURN IDENTIFIER

%%

prog_start: %empty /* epsilon */ {}
    | functions {}
    ;

functions: function {}
    | function functions {}
    ;

function: FUNCTION IDENTIFIER L_PAREN arguments R_PAREN L_CURLY statements R_CURLY {}
    ;

arguments: argument {}
    | argument COMMA arguments {}
    ;

argument: %empty /* epsilon */ {}
    | INTEGER IDENTIFIER {}
    ;

statements: %empty {}
    | statement SEMICOLON statements {}
    | statement_p statements {}
    ;

statement_p : s_if {}
    | s_while {}
    ;

statement: declaration {}
    | s_var {}
    | READ L_PAREN var R_PAREN {}
    | WRITE L_PAREN expression R_PAREN {}
    | RETURN expression {}
    ;

s_var: var EQUALS expression {}
    ;

s_if: IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY {}
    | IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY IFELSE neg L_CURLY statements R_CURLY {}
    | IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY ELSE L_CURLY statements R_CURLY {}
    ;

s_while: WHILELOOP L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY {}
    ;

expression: expression addop term {}
    | term {}
    ;

addop: PLUS {}
    | MINUS {}
    ;

term: term mulop factor {}
    | factor {}
    ;

mulop: MULT {}
    | DIV {}
    | MOD {}
    ;

factor: func L_PAREN expression R_PAREN {}
    | NUMBER {}
    | var {}
    | NUMBER DECIMAL NUMBER {}
    ;

func: %empty {}
    | IDENTIFIER {}
    ;

expression_bool: expression_bool ne_comp term_bool{}
    | term_bool {}
    ;

ne_comp: ISNOTEQUAL {}
    | LESSTHAN {}
    | GREATERTHAN {}
    ;

term_bool: term_bool e_comp factor_bool {}
    | factor_bool {}
    ;

e_comp: ISEQUAL {}
    | LTEQUAL {}
    | GTEQUAL {}
    ;

factor_bool: L_PAREN expression R_PAREN {}
    | NUMBER {}
    | var {}
    ;

var: IDENTIFIER {}
    | IDENTIFIER L_BRACKET NUMBER R_BRACKET {}
    ;

neg: 
        NOT {}
        | %empty /* epsilon */ {}
		;

declaration: INTEGER IDENTIFIER {}
    | INTEGER IDENTIFIER L_BRACKET expression R_BRACKET SEMICOLON{}
    ;

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
    printf("%s, line %d, pos %d\n", string);
}
