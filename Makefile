# only works with the Java extension of yacc: 
# byacc/j from http://troi.lincom-asg.com/~rjamison/byacc/

JFLEX  = java -jar jflex.jar
BYACCJ = ./yacc.linux -tv -J
JAVAC  = javac

# targets:

all: Parser.class

run: Parser.class
	java Parser

build: clean Parser.class

clean:
	rm -f *~ *.class *.o *.s Yylex.java Parser.java y.output

Parser.class: Yylex.java Parser.java
	$(JAVAC) Parser.java

Yylex.java: lista_dec_1.flex
	$(JFLEX) lista_dec_1.flex

Parser.java: byacc_grammar.y Yylex.java
	$(BYACCJ) byacc_grammar.y
