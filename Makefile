
all: parser

parser: lex.yy.cpp y.tab.cpp symbols.hpp
	g++ y.tab.cpp symbols.hpp -o my_parser -ll -ly -std=c++11 -Wno-deprecated-register

lex.yy.cpp: scanner.l
	lex -o lex.yy.cpp scanner.l

y.tab.cpp: parser.y
	yacc -d parser.y -o y.tab.cpp

clean:
	rm my_parser lex.yy.* y.tab.*
