all: 
	flex teehee_l.lex
	bison -v -d --file-prefix=y teehee.y
	g++ -o phase3 -x c++ y.tab.c lex.yy.c -lfl

close:
	rm -f phase3 lex.yy.c y.tab.c y.tab.h y.output *.mil
