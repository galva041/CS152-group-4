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
"isgiving"     {return EQUALS; posCount += yyleng;}
"less"     {return LESSTHAN; posCount += yyleng;}
"bigger"     {return GREATERTHAN; posCount += yyleng;}
"is"    {return ISEQUAL; posCount += yyleng;}
"isnt"    {return ISNOTEQUAL; posCount += yyleng;}
";"   {return SEMICOLON; posCount += yyleng;}
"("   {return L_PAREN; posCount += yyleng;}
")"   {return R_PAREN; posCount += yyleng;}
"{"   {return L_CURLY; posCount += yyleng;}
"}"   {return R_CURLY; posCount += yyleng;}
"["   {return L_BRACKET; posCount += yyleng;}
"]"   {return R_BRACKET; posCount += yyleng;}
","   {return COMMA; posCount += yyleng;}
"."   {return DECIMAL; posCount += yyleng;}
" "   {}
"\t"  {}
"\n"  {++lineCount; posCount = 1;}

:sob:.*\n {++lineCount; posCount = 1;}
yoink {return READ; posCount += yyleng;}
slout {return WRITE; posCount += yyleng;}
yaur\? {return IF; posCount += yyleng;}
aur\?  {return IFELSE; posCount += yyleng;}
naur  {return ELSE; posCount += yyleng;}
woil  {return WHILELOOP; posCount += yyleng;}
int   {return INTEGER; posCount += yyleng;}
queen  {return FUNCTION; posCount += yyleng;}
slay  {return RETURN}; posCount += yyleng;}

[a-zA-Z][a-zA-Z0-9]* {return IDENTIFIER;posCount += yyleng;}
[0-9][a-zA-Z0-9]* {printf("Invalid IDENTIFIER -> %s, line %d, position %d\n", yytext, lineCount, posCount); exit(0);}
.   {printf("ERROR: invalid character -> %s, line %d, position %d\n", yytext, lineCount, posCount); exit(0);}
%%