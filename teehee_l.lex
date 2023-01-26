%{
    #include <stdio.h>
%}

DIGIT [0-9]

%%
"+"      {printf("PLUS\n");} 
"-"      {printf("MINUS\n");} 
"*"      {printf("MULT\n");} 
"/"      {printf("DIV\n");} 
"isgiving"     {printf("EQUALS\n");}
"less"     {printf("LESSTHAN\n");}
"bigger"     {printf("GREATERTHAN\n");}
"is"    {printf("ISEQUAL\n");}
"isnt"    {printf("ISNOTEQUAL\n");}
";"   {printf("SEMICOLON\n");}
"("   {printf("L_PAREN\n");}
")"   {printf("R_PAREN\n");}
"{"   {printf("L_CURLY\n");}
"}"   {printf("R_CURLY\n");}
"["   {printf("L_BRACKET\n");}
"]"   {printf("R_BRACKET\n");}

%%

main()
{
  yylex();
}
