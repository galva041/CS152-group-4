%{
#include<stdio.h>
#include<string>
#include<vector>
#include<string.h>

extern int yylex(void);
void yyerror(const char *msg);
extern int currLine;

char *identToken;
int numberToken;
int  count_names = 0;


enum Type { Integer, Array };
struct Symbol {
  std::string name;
  Type type;
};
struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

std::vector <Function> symbol_table;


Function *get_function() {
  int last = symbol_table.size()-1;
  return &symbol_table[last];
}

bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

%}

%union {
  char *op_val;
}

%define parse.error verbose
%start prog_start
%token PLUS MINUS MULT MOD DIV EQUALS 
%token LESSTHAN GREATERTHAN ISEQUAL ISNOTEQUAL GTEQUAL LTEQUAL NOT 
%token SEMICOLON L_PAREN R_PAREN L_CURLY R_CURLY L_BRACKET R_BRACKET 
%token COMMA DECIMAL READ WRITE IF IFELSE ELSE WHILELOOP 
%token INTEGER FUNCTION RETURN
%token <op_val> NUMBER
%token <op_val> IDENTIFIER
%type <op_val> symbol

%%

prog_start: %empty /* epsilon */ {}
    | functions {}
    ;

functions: function {}
    | function functions {}
    ;

function: FUNCTION IDENTIFIER 
{
    std::string func_name = $2;
    add_function_to_symbol_table(func_name);
}
L_PAREN arguments R_PAREN L_CURLY statements R_CURLY{}
    ;

arguments: argument {}
    | argument COMMA arguments {}
    ;

argument: %empty /* epsilon */ {}
    | INTEGER IDENTIFIER
{
    // look up ident from symbol table?
    std::string value = $2;
    Type t = Integer;
    add_variable_to_symbol_table(value, t);
}
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

declaration: INTEGER IDENTIFIER
{
    std::string value = $2;
    Type t = Integer;
    add_variable_to_symbol_table(value, t);
}
    | INTEGER IDENTIFIER L_BRACKET expression R_BRACKET SEMICOLON
{
    // unnecessary?
}
    ;

%%

// void main(int argc, char** argv) {
//     if (argc >= 2) {
//         yyin = fopen(argv[1], "r");
//         if (yyin == NULL) 
//             yyin = stdin;
//     }
//     else {
//         yyin = stdin;
//     }
//     yyparse();
// }

int main(int argc, char **argv)
{
   yyparse();
   print_symbol_table();
   return 0;
}

void yyerror(const char *msg)
{
   printf("** Line %d: %s\n", currLine, msg);
   exit(1);
}