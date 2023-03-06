%{ 
    #include <stdio.h>
    int num_ints = 0, num_ops = 0, num_par = 0, num_eq = 0;
%}

DIGIT [0-9]
ALPHA [a-zA-Z]


%%
{DIGIT}+ {printf("NUMBER %s\n", yytext); num_ints++;}
"+"      {printf("PLUS\n"); ++num_ops;} 
"-"      {printf("MINUS\n"); ++num_ops;} 
"*"      {printf("MULT\n"); ++num_ops;} 
"/"      {printf("DIV\n"); ++num_ops;} 
"("      {printf("L_PAREN\n"); ++num_par;} 
")"      {printf("R_PAREN\n"); ++num_par;} 
"="      {printf("EQUAL\n"); ++num_eq;} 
.        {printf("Error! Invalid character!");}
%%

main(int argc, char* argv[]) {
    yyin = fopen(argv[1], "r");
    yylex();
    fclose(yyin);
    printf("# of ints = %d\n# of operators = %d\n# of paren = %d\n# of equal signs = %d\n", num_ints, num_ops, num_par, num_eq);   
}