output: lex.yy.c parser.tab.c
	g++ lex.yy.c parser.tab.c -o output

lex.yy.c: lexer.l
	flex lexer.l

parser.tab.c: parser.y
	bison -t -d parser.y

test: output
.PHONY: clean
clean:
	rm -f lex.yy.c parser.tab.c *.txt *.csv output test test.o test.s

assembly:
	g++ backend.cpp -o backend && ./backend 3AC.txt
s:
	gcc -c test.s -o test.o -fPIC && gcc test.o -o test -no-pie
	./test |  ./ascii.sh

s2:
	gcc -c test.s -o test.o -fPIC && gcc test.o -o test -no-pie
	./test 
default: test