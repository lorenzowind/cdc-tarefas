// Leonardo Vargas, Lorenzo Windmoller, Osmar Sadi

%%

%{
  private ListaDec1 yyparser;

  public Yylex(java.io.Reader r, ListaDec1 yyparser) {
    this(r);
    this.yyparser = yyparser;
  }
%} 

%integer
%line
%char

WHITE_SPACE_CHAR=[\n\r\ \t\b\012]

%%

"$TRACE_ON"   { yyparser.setDebug(true); }
"$TRACE_OFF"  { yyparser.setDebug(false); }

"while"	  { return ListaDec1.WHILE; }
"if"		  { return ListaDec1.IF; }
"else"	  { return ListaDec1.ELSE; }

"int"	    { return ListaDec1.INT; }
"double"  { return ListaDec1.DOUBLE; }
"boolean" { return ListaDec1.BOOLEAN; }

"func"	  { return ListaDec1.FUNC; }
"void"    { return ListaDec1.VOID; }

[:jletter:][:jletterdigit:]* { return ListaDec1.IDENT; }  

[0-9]+ 	{ return ListaDec1.NUM; }

"{" |
"}" |
"," |
";" |
"(" |
")" |
"+" |
"-" |
"*" |
"/" |
"="    { return yytext().charAt(0); } 

{WHITE_SPACE_CHAR}+ { }

. { System.out.println("Erro lexico: caracter invalido: <" + yytext() + ">"); }
