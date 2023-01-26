%{
    #include <stdio.h>
%}

DIGIT [0-9]
ALPHA [a-zA-Z]

%%
{DIGIT}+ {printf("NUMBER %s\n", yytext);}

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
" "   {}
"\t"  {}
"\n"  {}

:sob: {printf("COMMENT\n");}
yoink {printf("READ\n");}
slout {printf("WRITE\n");}
yaur\? {printf("IF\n");}
aur\?  {printf("ELSE IF\n");}
naur  {printf("ELSE\n");}
woil  {printf("WHILELOOP\n");}
int   {printf("INTEGER ");}

{ALPHA}+ {printf("%s\n", yytext);}
.   {printf("ERROR: invalid character -> %s\n", yytext); exit(0);}
%%

main(int argc, char* argv[]) {
  yyin = fopen(argv[1], "r");
  yylex();
  fclose(yyin);
}
