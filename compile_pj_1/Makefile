CC = g++ --std=c++11
main_cpp = main.cpp
lexer_lex = lexer.lex
target = main

main: $(main_cpp) lexer.o
	$(CC) $(main_cpp) lexer.o -o $(target)
	rm lexer.c *.o

lexer.o: lexer.c
	$(CC) -c lexer.c -o lexer.o

lexer.c: $(lexer_lex)
	flex -o lexer.c $(lexer_lex)

.PHONY: clean
clean:
	-rm -f lexer.c *.o $(target)
