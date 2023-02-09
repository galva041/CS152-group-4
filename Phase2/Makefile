all: 
	flex teehee_l.lex
	bison -v -d --file-prefix=y teehee.y
	gcc -o phase2 y.tab.c lex.yy.c -lfl

close:
	rm -f parser lex.yy.c y.tab.c y.tab.h y.output
