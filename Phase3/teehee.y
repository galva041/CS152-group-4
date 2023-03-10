%{
    #include "CodeNode.h"
    #include <stdio.h>
    #include<string>
    #include<vector>
    #include<string.h>
    #include "y.tab.h"

    extern int yylex(void);
    void yyerror(const char *msg);
    extern int lineCount;

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
  struct CodeNode *code_node;
  char *op_val;
  int int_val;
}

%define parse.error verbose
%start prog_start
%token PLUS MINUS MULT MOD DIV EQUALS LESSTHAN GREATERTHAN ISEQUAL ISNOTEQUAL GTEQUAL LTEQUAL NOT SEMICOLON L_PAREN R_PAREN L_CURLY R_CURLY L_BRACKET R_BRACKET COMMA DECIMAL READ WRITE IF IFELSE ELSE WHILELOOP INTEGER FUNCTION RETURN
%token <op_val> IDENTIFIER
%token <int_val> NUMBER
%type <code_node> functions function arguments argument declaration statement statements s_var s_if s_while expression var addop term mulop factor func expression_bool ne_comp term_bool e_comp factor_bool neg

%%

prog_start: %empty /* epsilon */ {}
    | functions {
        CodeNode *code_node = $1;
        printf("%s\n", code_node->code.c_str());
    }
    ;

functions: 
    function {
        CodeNode *node = new CodeNode;
        CodeNode *code_node1 = $1;
        node->code += code_node1->code;
        $$ = node; 
    }
    | function functions {
        CodeNode *code_node1 = $1;
        CodeNode *code_node2 = $2;
        CodeNode *node = new CodeNode;
        node->code += code_node1->code + code_node2->code;
        $$ = node; 
    }
    ;

function: FUNCTION IDENTIFIER L_PAREN arguments R_PAREN L_CURLY statements R_CURLY 
{
    CodeNode *node = new CodeNode;
    std::string func_name = $2;
    node->code = "";
    node->code += std::string("func ") + func_name + std::string("\n");

    // params arguments
    CodeNode *arguments = $4;
    node->code += arguments->code;

    // statements
    CodeNode *statements = $7;
    node->code += statements->code;
    $$ = node;
}
    ;

arguments: argument {}
    | argument COMMA arguments {}
    ;

argument: %empty /* epsilon */ {
        CodeNode *node = new CodeNode;
        $$ = node; 
    }
    | INTEGER IDENTIFIER {
        CodeNode *code_node1 = new CodeNode;
        std::string id = $2;
        code_node1->code += std::string(". ") + id + std::string("\n");
        $$ = code_node1;
    }
    ;

statements: %empty {
        CodeNode *node = new CodeNode;
        $$ = node; 
    }
    | statement SEMICOLON statements {
        CodeNode *code_node1 = $1;
        CodeNode *code_node2 = $3;
        CodeNode *node = new CodeNode;
        
        node->code += code_node1->code + code_node2->code;
        $$ = node;
    }
    | statement_p statements {
        // CodeNode *code_node1 = $1;
        // CodeNode *code_node2 = $2;
        // CodeNode *node = new CodeNode;
        // node->code += code_node1->code + code_node2->code;
        // $$ = node;
    }
    ;

statement_p : s_if {}
    | s_while {}
    ;

statement: 
    declaration {
        CodeNode *node = new CodeNode;
        node->code += $1->code;
        $$ = node;
    }
    | s_var {
        CodeNode *node = new CodeNode;
        CodeNode *code_node1 = $1;

        node->code += code_node1->code;
        $$ = node;
    }
    | READ L_PAREN var R_PAREN {}
    | WRITE L_PAREN expression R_PAREN {}
    | RETURN expression {}
    ;

s_var: var EQUALS expression {
    CodeNode *node = new CodeNode;
    node->code = $3->code;

    node->code += std::string("= ") + $1->name + std::string(", ") + $3->name + std::string("\n");
    $$ = node;
}
    ;

s_if: IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY {}
    | IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY IFELSE neg L_CURLY statements R_CURLY {}
    | IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY ELSE L_CURLY statements R_CURLY {}
    ;

s_while: WHILELOOP L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY {}
    ;

expression: expression addop term {
    CodeNode *node = new CodeNode;
    CodeNode *expression = $1;
    CodeNode *addop = $2;
    CodeNode *term = $3;
    
    node->code += expression->code + addop->code + term->code;
    $$ = node;
}
    | term {
        CodeNode *node = new CodeNode;
        CodeNode *term = $1;
        
        node->code += term->code;
        $$ = node;
    }
    ;

addop: PLUS {}
    | MINUS {}
    ;

term: term mulop factor {
    CodeNode *node = new CodeNode;
    CodeNode *term = $1;
    CodeNode *mulop = $2;
    CodeNode *factor = $3;
    
    node->code += term->code + mulop->code + factor->code;
    $$ = node;
}
    | factor {
        CodeNode *node = new CodeNode;
        CodeNode *factor = $1;
        
        node->code += factor->code;
        $$ = node;
    }
    ;

mulop: MULT {}
    | DIV {}
    | MOD {}
    ;

factor: func L_PAREN expression R_PAREN {
    CodeNode *node = new CodeNode;
    node->code += $1->code + $3->code;
    $$ = node;
}
    | NUMBER {
        CodeNode *node = new CodeNode;
        node->code = "";
        node->name = $1;
        $$ = node;
    }
    | var {
        CodeNode *node = new CodeNode;
        node->code = $1->code;
        $$ = node;
    }
    | NUMBER DECIMAL NUMBER {
        CodeNode *node = new CodeNode;
        node->code = "";
        node->name = $1;
        $$ = node;
    }
    ;

func: %empty {
    CodeNode *node = new CodeNode;
    $$ = node;
}
    | IDENTIFIER {
        CodeNode *node = new CodeNode;
        node->code = "";
        node->name = $1;
        $$ = node;
    }
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
    | NUMBER {
        CodeNode *node = new CodeNode;
        node->code = "";
        node->name = $1;
        $$ = node;
    }
    | var {}
    ;

var: IDENTIFIER {
    CodeNode *node = new CodeNode;
    node->code = "";
    node->name = $1;
    $$ = node;
}
    | IDENTIFIER L_BRACKET NUMBER R_BRACKET {
        std::string name = $1;
        CodeNode *node = new CodeNode;
        node->code = "";
        node->name = name;
        $$ = node;
    }
    ;

neg: 
        NOT {}
        | %empty /* epsilon */ {}
		;

declaration: INTEGER IDENTIFIER  {
        CodeNode *node = new CodeNode;
        std::string id = $2;
        node->code += std::string(". ") + id + std::string("\n");
        $$ = node;
    }
     | INTEGER IDENTIFIER EQUALS expression  {
         CodeNode *code_node1 = new CodeNode;
         std::string id = $2;
         CodeNode *expression = $4;
         code_node1->code += expression->code;
         code_node1->code += std::string(". hello") + id + expression->name + std::string("\n");
         $$ = code_node1; 
     }
    | INTEGER IDENTIFIER L_BRACKET expression R_BRACKET 
    {
        // CodeNode *node = new CodeNode;
        // // identifier name
        // CodeNode *code_node1 = new CodeNode;
        // std::string id = $2;
        // code_node1->code += std::string(". ") + id + std::string("\n");

        // // expressions 
        // CodeNode *expression = $4;
        // code_node1->code += expression->code;

        // $$ = node;
    }
    ;

%%

int main(int argc, char **argv)
{
    yyparse();
//    print_symbol_table();
   return 0;
}

void yyerror(const char *msg)
{
   printf("** Line %d: %s\n", lineCount, msg);
   exit(1);
}