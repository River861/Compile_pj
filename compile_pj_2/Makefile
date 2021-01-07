CC = g++ --std=c++11
BISON = bison --warnings=none
FLEX = flex

yacc_y = yacc.y
lexer_l = lexer.l
main_cpp = main.cpp
target = main

main: $(main_cpp) yacc.o
	$(CC) $(main_cpp) yacc.o -o $(target)
	rm yacc.c yacc.h lexer.c *.o

yacc.o: yacc.c
	$(CC) -c yacc.c -o yacc.o

yacc.c: $(yacc_y) lexer.c
	$(BISON) -o yacc.c -d $(yacc_y)

lexer.c: $(lexer_l)
	$(FLEX) -o lexer.c $(lexer_l)

.PHONY: clean
clean:
	-rm -f yacc.c yacc.h lexer.c *.o $(target)
