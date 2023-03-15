%{
    #include "CodeNode.h"
    #include <stdio.h>
    #include<string>
    #include<vector>
    #include<string.h>
    #include "y.tab.h"
    #include <sstream>

    extern int yylex(void);
    void yyerror(const char *msg);
    extern int lineCount;
    int position = 0;
    char *identToken;
    int numberToken;
    int  count_names = 0;
    int count_temp = 0;
    int count_loops = 0;
    int count_ifs = 0;
    int count_elses = 0;

std::string create_temp() {
    std::stringstream temp; 
    temp << "_temp" << count_temp;
    count_temp += 1;
    return temp.str();
}

std::string create_loop(){
    std::stringstream loop;
    loop << count_loops;
    count_loops += 1;
    return loop.str();
}

std::string create_ifs(){
    std::stringstream ifs;
    ifs << count_ifs;
    count_ifs += 1;
    return ifs.str();
}

std::string create_else(){
    std::stringstream elses;
    elses << count_elses;
    count_elses += 1;
    return elses.str();
}

enum Type { Integer, Array };
struct Symbol {
  std::string name;
  Type type;
  int symCount;
};
struct Function {
  std::string name;
//   std::vector<Symbol> declarations;
  int funcCount;
};

std::vector <Function> symbol_table;
std::vector <Symbol> declarations;

Function *get_function() {
  int last = symbol_table.size()-1;
  return &symbol_table[last];
}

bool find(std::string &value) {
//   Function *f = get_function();
//   for(int i=0; i < f->declarations.size(); i++) {
  for(int i=0; i < declarations.size(); i++) {
    // Symbol *s = declarations[i];
    Symbol s = declarations[i];
    if (s.name == value) {
      return true;
    }
  }
  return false;
}

void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  f.funcCount = position;
  position++;
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  s.symCount = position;
//   Function *f = get_function();
//   f->declarations.push_back(s);
  declarations.push_back(s);
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<declarations.size(); j++) {
        if (symbol_table[i].funcCount == declarations[j].symCount) 
          printf("  locals: %s\n", declarations[j].name.c_str());
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
%token PLUS MINUS MULT MOD DIV EQUALS LESSTHAN GREATERTHAN ISEQUAL ISNOTEQUAL GTEQUAL LTEQUAL NOT SEMICOLON L_PAREN R_PAREN L_CURLY R_CURLY L_BRACKET R_BRACKET COMMA DECIMAL READ WRITE IF IFELSE ELSE WHILELOOP INTEGER FUNCTION RETURN BREAK
%token <op_val> IDENTIFIER NUMBER
%type <code_node> functions function arguments argument declaration statement statement_p statements s_var s_if s_while expression var addop term mulop factor func expression_bool ne_comp term_bool e_comp factor_bool neg arr_assn arr_access arr_decl

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

    node->code += std::string("endfunc\n");
    $$ = node;

    add_function_to_symbol_table(func_name);
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

        // Type t = Integer;
        // add_variable_to_symbol_table(id , t);
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
        CodeNode *node = new CodeNode;
        node-> code += $1->code + $2->code;
        $$ = node;
    }
    ;

statement_p : s_if {
        CodeNode *node = new CodeNode;
        node = $1;
        $$ = node; 
    }
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
        node->name = code_node1->name;
        $$ = node;
    }
    | READ L_PAREN var R_PAREN {}
    | WRITE L_PAREN expression R_PAREN {
        CodeNode *node = new CodeNode;
        CodeNode *expression = $3;
        std::string id = expression->name;
        node->code = expression->code;
        node->code += std::string(".> ") + id + std::string("\n");
        $$ = node;
    }
    | arr_decl {
        // CodeNode *node = new CodeNode;
        // node->code += $1->code;
        // node->name = $1->name;
        // $$ = node;
    }
    | arr_assn {
        // CodeNode *node = new CodeNode;
        // node->code += $1->code;
        // node->name = $1->name;
        // $$ = node;
    }
    | BREAK {
        CodeNode *node = new CodeNode;
        std::stringstream str_s;
        str_s << count_loops;
        std::string num;
        str_s >> num;
        node->code = std::string(":= endloop") + num + std::string("\n");
        $$ = node;
    }
    | RETURN expression {}
    ;

arr_decl: INTEGER IDENTIFIER L_BRACKET NUMBER R_BRACKET  {
    // std::string tmp = create_temp();
    // CodeNode *tmp_node = new CodeNode;
    // tmp_node->name = tmp;
    // tmp_node->code += tmp;

    std::string id = $2;
    std::string num = $4;
    
    CodeNode *node = new CodeNode;
    node->code = std::string(".[] ") + id + std::string(", ") + num + std::string("\n");
    node->name = id;
    Type t = Integer;
    add_variable_to_symbol_table(id , t);
    $$ = node;
}
    ;

arr_assn: IDENTIFIER L_BRACKET NUMBER R_BRACKET EQUALS expression {
    //std::string temp = create_temp();
    std::string name = $1;
    std::string num = $3;

    CodeNode *node = new CodeNode;
    //node->code = std::string(". ") + temp + std::string("\n");
    node->code += $6->code;
    node->code += std::string("[]= ") + name + std::string(", ") + num + std::string(", ") + $6->name + std::string("\n");
    $$ = node;
}
    ;

s_var: var EQUALS expression {
    CodeNode *node = new CodeNode;
    node->code = $3->code;
    node->name = $1->name;

    node->code += std::string("= ") + $1->name + std::string(", ") + $3->name + std::string("\n");
    $$ = node;
}
    ;

s_if: IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY {
        std::string ifs = create_ifs();

        CodeNode *node = new CodeNode;
        CodeNode *neg = $3;
        CodeNode *expression_bool = $4;
        CodeNode *statements = $7;

        node->code += neg->code + expression_bool->code;
        node->code += std::string("?:= if_true") + ifs + std::string(", ") + expression_bool->name + std::string("\n");
        node->code += std::string(":= endif") + ifs + std::string("\n"); 

        node->code += std::string(": if_true") + ifs + std::string("\n");
        node->code += statements->code;

        node->code += std::string(": endif") + ifs + std::string("\n");
        
        $$ = node;
    }
    | IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY IFELSE neg L_CURLY statements R_CURLY {
        
    }
    | IF L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY ELSE L_CURLY statements R_CURLY {
        std::string ifs = create_ifs();

        CodeNode *node = new CodeNode;
        CodeNode *neg = $3;
        CodeNode *expression_bool = $4;
        CodeNode *statements_if = $7;
        CodeNode *statements_else = $11;

        node->code += neg->code + expression_bool->code;
        node->code += std::string("?:= if_true") + ifs + std::string(", ") + expression_bool->name + std::string("\n");

        node->code += std::string(":= else") + ifs + std::string("\n");

        node->code += std::string(": if_true") + ifs + std::string("\n");
        node->code += statements_if->code;  
        node->code += std::string(":= endif") + ifs + std::string("\n");

        node->code += std::string(": else") + ifs + std::string("\n");
        node->code += statements_else->code;

        node->code += std::string(": endif") + ifs + std::string("\n");
        
        $$ = node;
    }
    ;

s_while: WHILELOOP L_PAREN neg expression_bool R_PAREN L_CURLY statements R_CURLY {
    std::string loop = create_loop();
    CodeNode *node = new CodeNode;

    node->code = std::string(": beginloop") + loop + std::string("\n");

    //neg
    node->code += $3->code;

    //exp-bool
    node->code += $4->code;
    node->code += std::string("?:= loopbody") + loop + std::string(", ") + $4->name + std::string("\n");
    node->code += std::string(":= endloop") + loop + std::string("\n");

    node->code += std::string(": loopbody") + loop + std::string("\n");
    
    //statements
    node->code += $7->code;

    node->code += std::string(":= beginloop") + loop + std::string("\n");
    node->code += std::string(": endloop") + loop + std::string("\n");

    $$ = node;
}   
    ;

expression: expression addop term {
    std::string temp = create_temp();

    CodeNode* addop_node = $2;

    CodeNode *node = new CodeNode;
    node->code = $1->code + $3->code + std::string(". ")  + temp + std::string("\n");

    node->code += addop_node->name + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
    node->name = temp;
    $$ = node; 
}
    | term {
        CodeNode *node = new CodeNode;
        CodeNode *term = $1;
        
        node->name = term->name;
        node->code += term->code;
        $$ = node;
    }
    ;

addop: PLUS {
        CodeNode* node = new CodeNode;
        node->name = std::string("+ ");
        node->code += "";
        $$ = node;
    }
    | MINUS {
        CodeNode* node = new CodeNode;
        node->name = std::string("- ");
        node->code += "";
        $$ = node;
    }
    ;

term: term mulop factor {
    std::string temp = create_temp();

    CodeNode* mulop_node = $2;
  
    CodeNode *node = new CodeNode;
    node->code = $1->code + $3->code + std::string(". ")  + temp  + std::string("\n");

    node->code += mulop_node->name + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
    node->name = temp;
    $$ = node; 
}
    | factor {
        CodeNode *node = new CodeNode;
        CodeNode *factor = $1;
        
        node->name = factor->name;
        node->code += factor->code;
        $$ = node;
    }
    ;

mulop: MULT {
        CodeNode* node = new CodeNode;
        node->name = std::string("* ");
        node->code += "";
        $$ = node;
    }   
    | DIV {
        CodeNode* node = new CodeNode;
        node->name = std::string("/ ");
        node->code += "";
        $$ = node;
    }
    | MOD {
        CodeNode* node = new CodeNode;
        node->name = std::string("\% ");
        node->code += "";
        $$ = node;
    }
    ;

factor: func L_PAREN expression R_PAREN {
    CodeNode *node = new CodeNode;
    node->name = $3->name;
    node->code += $1->code + $3->code;
    $$ = node;
}
    | NUMBER {
        CodeNode *node = new CodeNode;
        //node->code = "";
        node->name = $1;
        $$ = node;
    }
    | var {
        CodeNode *node = new CodeNode;
        node->code = $1->code;
        node->name = $1->name;
        $$ = node;
    }
    | NUMBER DECIMAL NUMBER {
        CodeNode *node = new CodeNode;
        node->code = "";
        node->name = $1;
        $$ = node;
    }
    | arr_access {
        CodeNode *node = new CodeNode;
        node->code = $1->code;
        node->name = $1->name;
        $$ = node;
    }
    ;

arr_access: IDENTIFIER L_BRACKET NUMBER R_BRACKET {
        std::string id = $1;
        std::string index = $3;
        std::string tmp = create_temp();

        CodeNode *node = new CodeNode;
        node->name = tmp;
        node->code = std::string(". ") + tmp + std::string("\n");
        node->code += std::string("=[] ") + tmp + std::string(", ") + id + std::string(", ") + index + std::string("\n");

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

expression_bool: expression_bool ne_comp term_bool{
        std::string temp = create_temp();
        
        CodeNode *node = new CodeNode;
        node->code = $1->code + $3->code + std::string(". ") + temp + std::string("\n");
        node->code += $2->name + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
        node->name = temp;
        $$ = node;
}
    | term_bool {
        CodeNode *node = new CodeNode;
        node->code += $1->code;
        node->name = $1->name;
        $$ = node;
    }
    ;

ne_comp: ISNOTEQUAL {
        CodeNode* node = new CodeNode;
        node->name = std::string("!= ");
        node->code += "";
        $$ = node;
}
    | LESSTHAN {
        CodeNode* node = new CodeNode;
        node->name = std::string("< ");
        node->code += "";
        $$ = node;
    }
    | GREATERTHAN {
        CodeNode* node = new CodeNode;
        node->name = std::string("> ");
        node->code += "";
        $$ = node;
    }
    ;

term_bool: term_bool e_comp factor_bool {
        std::string temp = create_temp();
        
        CodeNode *node = new CodeNode;
        node->code = $1->code + $3->code + std::string(". ") + temp + std::string("\n");
        node->code += $2->name + temp + std::string(", ") + $1->name + std::string(", ") + $3->name + std::string("\n");
        node->name = temp;
        $$ = node;
}
    | factor_bool {
        CodeNode *node = new CodeNode;
        node->code = $1->code;
        node->name = $1->name;
        $$ = node;
    }
    ;

e_comp: ISEQUAL {
        CodeNode* node = new CodeNode;
        node->name = std::string("== ");
        node->code += "";
        $$ = node;
}
    | LTEQUAL {
        CodeNode* node = new CodeNode;
        node->name = std::string("<= ");
        node->code += "";
        $$ = node;
    }
    | GTEQUAL {
        CodeNode* node = new CodeNode;
        node->name = std::string(">= ");
        node->code += "";
        $$ = node;
    }
    ;

factor_bool: factor_bool L_PAREN expression R_PAREN {
        CodeNode *node = new CodeNode;
        node->code += $1->code + $3->code;
        node->name = $3->name;
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
        node->name = $1->name;
        $$ = node;
    }
    ;

var: IDENTIFIER {
    CodeNode *node = new CodeNode;
    node->code = "";
    node->name = $1;
    std::string error = "The variable " + node->name + " has not been declared\n";
    if (!find(node->name)) {
        yyerror(error.c_str());
    }
    $$ = node;
}
    ;

neg: 
    NOT {
        CodeNode* node = new CodeNode;
        node->name = std::string("! ");
        node->code += "";
        $$ = node;
    }
    | %empty /* epsilon */ {
        CodeNode *node = new CodeNode;
        $$ = node;
    }
    ;

declaration: INTEGER IDENTIFIER  {
        CodeNode *node = new CodeNode;
        std::string id = $2;
        node->code += std::string(". ") + id + std::string("\n");
        $$ = node;

        Type t = Integer;
        add_variable_to_symbol_table(id , t);
    }
    ;

%%

int main(int argc, char **argv)
{
   yyparse();
    print_symbol_table();
   return 0;
}

void yyerror(const char *msg)
{
   printf("** Line %d: %s\n", lineCount, msg);
   exit(1);
}