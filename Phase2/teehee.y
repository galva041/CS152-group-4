%{
    #include <stdio.h>
    extern FILE* yyin
%}

%start prog_start
%token PLUS MINUS MULT DIV EQUALS LESSTHAN GREATERTHAN ISEQUAL ISNOTEQUAL SEMICOLON L_PAREN R_PAREN L_CURLY R_CURLY L_BRACKET R_BRACKET COMMA DECIMAL READ WRITE IF IFELSE ELSE WHILELOOP INTEGER FUNCTION RETURN IDENTIFIER

%%

prog_start: %empty /* epsilon */ {printf("prog_start -> epsilon\n");}
    | functions {printf("prog_start -> functions\n");}
    ;

functions: function {printf("functions -> function\n");}
    | function functions {printf("functions -> function functions\n");}
    ;

function: INT IDENTIFIER L_PAREN arguments R_PAREN L_CURLY statements R_CURLY {printf("function -> INT IDENTIFIER L_PAREN arguments R_PAREN L_CURLY statements R_CURLY\n");}
        ;

arguments: argument {printf("arguments -> argument\n");}
    | argument COMMA arguments {printf("arguments -> argument COMMA arguments\n");}
    ;

argument: %empty /* epsilon */ {printf("argument -> epsilon\n");}
    | INT IDENTIFIER {printf("argument -> INT IDENTIFIER\n");}
    ;

statements: declaration {printf("statements -> declaration\n");}
    | statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
    ;

statement: declaration {printf("statement -> declaration\n");}
    | function_call {printf("statement -> function_call\n");}
    ;

declaration: INT IDENTIFIER {printf("declaration -> INT IDENTIFIER\n"));}
    ;

function_call: IDENTIFIER L_PAREN args R_PAREN {printf("function_call -> IDENTIFIER L_PAREN args R_PAREN\n");}
    ;

args: %empty {printf("args -> epsilon\n");} 
    ;

%%

void main(int argc, char** argv) {
    if (argc >= 2) {
        yyin = fopen()argv[1], "r";
        if (yyin == NULL) 
            yyin = stdin;
    }
    else {
        yyin = stdin;
    }
    yyparse();
}
int yyerror();