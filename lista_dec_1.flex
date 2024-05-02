// Leonardo Vargas, Lorenzo Windmoller, Osmar Sadi
%%

%byaccj

%{
  private Parser yyparser;

  public Yylex(java.io.Reader r, Parser yyparser) {
    this(r);
    this.yyparser = yyparser;
  }
%}

NL  = \n | \r | \r\n

%%

"$TRACE_ON"  { yyparser.setDebug(true);  }
"$TRACE_OFF" { yyparser.setDebug(false); }

"while"	  { return Parser.WHILE; }
"if"		  { return Parser.IF; }
"else"	  { return Parser.ELSE; }

"int"	    { return Parser.INT; }
"double"  { return Parser.DOUBLE; }
"boolean" { return Parser.BOOLEAN; }

"func"	  { return Parser.FUNC; }
"void"    { return Parser.VOID; }

"&&" { return Parser.AND; }
"||" { return Parser.OR; }
"!"  { return Parser.NOT; }
"==" { return Parser.EQ; }
"!=" { return Parser.NEQ; }
"<"  { return Parser.LT; }
">"  { return Parser.GT; }
"<=" { return Parser.LE; }
">=" { return Parser.GE; }

[0-9]+ { return Parser.num;}
[a-zA-Z][a-zA-Z0-9]* { return Parser.ident;}

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

[ \t]+ { }
{NL}+  { }

.    { System.err.println("Error: unexpected character '"+yytext()+"' na linha "+yyline); return YYEOF; }
