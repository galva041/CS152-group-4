%{
    #include <stdio.h>

    int lineCount = 1;
    int posCount = 1;
%}

DIGIT [0-9]
ALPHA [a-zA-Z]

%%
{DIGIT}+ {return NUMBER; posCount+= yyleng;}

"+"      {return PLUS; posCount += yyleng;} 
"-"      {return MINUS; posCount += yyleng;} 
"*"      {return MULT; posCount += yyleng;} 
"/"      {return DIV; posCount += yyleng;} 
"isgiving"     {printf("EQUALS\n"); posCount += yyleng;}
"less"     {printf("LESSTHAN\n"); posCount += yyleng;}
"bigger"     {printf("GREATERTHAN\n"); posCount += yyleng;}
"is"    {printf("ISEQUAL\n"); posCount += yyleng;}
"isnt"    {printf("ISNOTEQUAL\n"); posCount += yyleng;}
";"   {printf("SEMICOLON\n"); posCount += yyleng;}
"("   {printf("L_PAREN\n"); posCount += yyleng;}
")"   {printf("R_PAREN\n"); posCount += yyleng;}
"{"   {printf("L_CURLY\n"); posCount += yyleng;}
"}"   {printf("R_CURLY\n"); posCount += yyleng;}
"["   {printf("L_BRACKET\n"); posCount += yyleng;}
"]"   {printf("R_BRACKET\n"); posCount += yyleng;}
","   {printf("COMMA\n"); posCount += yyleng;}
"."   {printf("DECIMAL\n"); posCount += yyleng;}
" "   {}
"\t"  {}
"\n"  {++lineCount; posCount = 1;}

:sob:.*\n {++lineCount; posCount = 1;}
yoink {printf("READ\n"); posCount += yyleng;}
slout {printf("WRITE\n"); posCount += yyleng;}
yaur\? {printf("IF\n"); posCount += yyleng;}
aur\?  {printf("ELSE IF\n"); posCount += yyleng;}
naur  {printf("ELSE\n"); posCount += yyleng;}
woil  {printf("WHILELOOP\n"); posCount += yyleng;}
int   {printf("INTEGER\n"); posCount += yyleng;}
queen  {printf("FUNCTION\n"); posCount += yyleng;}
slay  {printf("RETURN\n"); posCount += yyleng;}

[a-zA-Z][a-zA-Z0-9]* {printf("IDENTIFIER %s\n", yytext);posCount += yyleng;}
[0-9][a-zA-Z0-9]* {printf("Invalid IDENTIFIER -> %s, line %d, position %d\n", yytext, lineCount, posCount); exit(0);}
.   {printf("ERROR: invalid character -> %s, line %d, position %d\n", yytext, lineCount, posCount); exit(0);}
%%