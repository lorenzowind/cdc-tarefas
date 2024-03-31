JFLEX  = java -jar jflex.jar
JAVAC  = javac

# targets:

all: ListaDec1.class

clean:
	rm -f *~ *.class Yylex.java

ListaDec1.class: ListaDec1.java Yylex.java
	$(JAVAC) ListaDec1.java

Yylex.java: lista_dec_1.flex
	$(JFLEX) lista_dec_1.flex

