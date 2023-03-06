%{
    #include "y.tab.h"

    int lineCount = 1;
    int posCount = 1;
%}

DIGIT [0-9]
ALPHA [a-zA-Z]

%%
{DIGIT}+ {return NUMBER; posCount+= yyleng;}

"+"      {posCount += yyleng; return PLUS;}
"-"      {posCount += yyleng; return MINUS;}
"*"      {posCount += yyleng; return MULT;}
"/"      {posCount += yyleng; return DIV;}
"%"      {posCount += yyleng; return MOD;}
"isgiving"     {posCount += yyleng; return EQUALS;}
"less"     {posCount += yyleng; return LESSTHAN;}
"bigger"     {posCount += yyleng; return GREATERTHAN;}
"is"    {posCount += yyleng; return ISEQUAL;}
"isnt"    {posCount += yyleng; return ISNOTEQUAL;}
"isgivingsmall" {posCount += yyleng; return LTEQUAL;}
"isgivingbigger" {posCount += yyleng; return GTEQUAL;}
";"   {posCount += yyleng; return SEMICOLON;}
"("   {posCount += yyleng; return L_PAREN;}
")"   {posCount += yyleng; return R_PAREN;}
"{"   {posCount += yyleng; return L_CURLY;}
"}"   {posCount += yyleng; return R_CURLY;}
"["   {posCount += yyleng; return L_BRACKET;}
"]"   {posCount += yyleng; return R_BRACKET;}
","   {posCount += yyleng; return COMMA;}
"."   {posCount += yyleng; return DECIMAL;}
" "   {}
"\t"  {}
"\n"  {++lineCount; posCount = 1;}
"naurt" {posCount += yyleng; return NOT;}

:sob:.*\n {++lineCount; posCount = 1;}
yoink {posCount += yyleng; return READ;}
slout {posCount += yyleng; return WRITE;}
yaur\? {posCount += yyleng; return IF;}
aur\?  {posCount += yyleng; return IFELSE;}
naur  {posCount += yyleng; return ELSE;}
woil  {posCount += yyleng; return WHILELOOP;}
int   {posCount += yyleng; return INTEGER;}
queen  {posCount += yyleng; return FUNCTION;}
slay  {posCount += yyleng; return RETURN;}

[a-zA-Z][a-zA-Z0-9]* {posCount += yyleng; return IDENTIFIER;}
[0-9][a-zA-Z0-9]* {printf("Invalid IDENTIFIER -> %s, line %d, position %d\n", yytext, lineCount, posCount); exit(0);}
.   {printf("ERROR: invalid character -> %s, line %d, position %d\n", yytext, lineCount, posCount); exit(0);}
%%
