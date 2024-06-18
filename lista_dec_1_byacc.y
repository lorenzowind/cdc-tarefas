%{
  import java.io.*;
%}

%token INT DOUBLE BOOLEAN VOID FUNC WHILE IF ELSE num ident
%token AND OR NOT EQ NEQ LT LE GT GE
%token RETURN

%left AND
%left OR
%right NOT
%right EQ NEQ
%nonassoc LT GT
%nonassoc LE GE
%left '+' '-'
%left '*' '/'

%type <sval> ident
%type <ival> num
%type <obj> Tipo
%type <obj> E
%type <obj> T
%type <obj> F
%type <obj> lvalue

%%

Prog : ListaDecl
     ;

ListaDecl : { currClass = ClasseID.VarGlobal; } Decl
          |
          ;

Decl : DeclVar ListaDecl
     | DeclFun ListaDecl
     | DeclIndex ListaDecl
     ;

DeclVar : Tipo { currentType = (TS_entry)$1; } ListaIdent ';'
        ;

DeclIndex : Tipo { currentType = (TS_entry)$1; } DeclMultIndex ListaIdent ';' 
          ;

DeclMultIndex : '[' ']' '[' ']' 
              | '[' ']' 
              ;
              
Tipo : INT     { $$ = Tp_INT; }
     | DOUBLE  { $$ = Tp_DOUBLE; }
     | BOOLEAN { $$ = Tp_BOOL; }
     ;

ListaIdent : ident ',' ListaIdent { TS_entry nodo = ts.pesquisa($1);
                                    if (nodo != null) 
                                      yyerror("(sem) variavel >" + $1 + "< jah declarada");
                                    else
                                      ts.insert(new TS_entry($1, currentType, currClass)); 
                                  }
           | ident                { TS_entry nodo = ts.pesquisa($1);
                                    if (nodo != null) 
                                      yyerror("(sem) variavel >" + $1 + "< jah declarada");
                                    else 
                                      ts.insert(new TS_entry($1, currentType, currClass)); 
                                  }
           ;

DeclFun : FUNC TipoOuVoid ident { currClass = ClasseID.VarLocal; } '(' FormalPar ')' Bloco
        ;

Bloco : '{' DeclVarOpt ListaCmdOpt '}'
      ;

DeclVarOpt : DeclVar ListaDecl
           |
           ;

ListaCmdOpt : ListaCmd
            |
            ;

TipoOuVoid : Tipo
           | VOID
           ;

FormalPar : ParamList
          |
          ;

ParamList : Tipo ident ',' ParamList {  TS_entry nodo = ts.pesquisa($2);
                                        if (nodo != null) 
                                          yyerror("(sem) variavel >" + $2 + "< jah declarada");
                                        else ts.insert(new TS_entry($2, (TS_entry)$1, currClass)); 
                                     }
          | Tipo ident               {  TS_entry nodo = ts.pesquisa($2);
                                        if (nodo != null) 
                                          yyerror("(sem) variavel >" + $2 + "< jah declarada");
                                        else ts.insert(new TS_entry($2, (TS_entry)$1, currClass)); 
                                     }
          ;

ListaCmd : Cmd ListaCmd
         |
         ;

Cmd : Bloco
    | WHILE '(' E ')' Cmd       { if (((TS_entry)$3) != Tp_BOOL) 
                                    yyerror("(sem) expressão (while) deve ser lógica "+((TS_entry)$3).getTipo());
                                }
    | lvalue '=' E ';'          
    | IF '(' E ')' Cmd RestoIf  { if (((TS_entry)$3) != Tp_BOOL) 
                                    yyerror("(sem) expressão (if) deve ser lógica "+((TS_entry)$3).getTipo());
                                }
    | RETURN E ';'
    | RETURN ';'
    | FuncCall ';'
    ;

lvalue : ident          { TS_entry nodo = ts.pesquisa($1);
                          if (nodo == null) {
                            yyerror("(sem) var <" + $1 + "> nao declarada"); 
                            $$ = Tp_ERRO;    
                          }           
                          else
                            $$ = nodo.getTipo();
                        } 
       | ident NumIndex { TS_entry nodo = ts.pesquisa($1);
                          if (nodo == null) {
                            yyerror("(sem) var <" + $1 + "> nao declarada"); 
                            $$ = Tp_ERRO;    
                          }           
                          else
                            $$ = nodo.getTipo();
                        }
       ;

NumIndex : '[' num ']' '[' num ']' 
         | '[' num ']' 
         ;

RestoIf : ELSE Cmd
        |
        ;

FuncCall : ident '(' ExprList ')'
         ;

ExprList : E ',' ExprList
         | E
         |
         ;

E : E OR E  { $$ = validaTipo(OR, (TS_entry)$1, (TS_entry)$3); }
  | E AND E { $$ = validaTipo(AND, (TS_entry)$1, (TS_entry)$3); }
  | E EQ E  { $$ = validaTipo(EQ, (TS_entry)$1, (TS_entry)$3); }
  | E NEQ E { $$ = validaTipo(NEQ, (TS_entry)$1, (TS_entry)$3); }
  | E LT E  { $$ = validaTipo(LT, (TS_entry)$1, (TS_entry)$3); }
  | E GT E  { $$ = validaTipo(GT, (TS_entry)$1, (TS_entry)$3); }
  | E LE E  { $$ = validaTipo(LE, (TS_entry)$1, (TS_entry)$3); }
  | E GE E  { $$ = validaTipo(GE, (TS_entry)$1, (TS_entry)$3); }
  | E '+' E { $$ = validaTipo('+', (TS_entry)$1, (TS_entry)$3); }
  | E '-' E { $$ = validaTipo('-', (TS_entry)$1, (TS_entry)$3); }
  | T       { $$ = $1; }
  ;

T : T '*' T { $$ = validaTipo('*', (TS_entry)$1, (TS_entry)$3); }
  | T '/' T { $$ = validaTipo('/', (TS_entry)$1, (TS_entry)$3); }
  | F       { $$ = $1; }
  ;

F : '(' E ')'      {  $$ = $2; }
  | NOT F          {  $$ = validaTipo(NOT, (TS_entry)$2); }
  | ident          {  TS_entry nodo = ts.pesquisa($1);
                      if (nodo == null) {
                        yyerror("(sem) var <" + $1 + "> nao declarada"); 
                        $$ = Tp_ERRO;    
                      }           
                      else
                        $$ = nodo.getTipo();
                   } 
  | ident NumIndex {  TS_entry nodo = ts.pesquisa($1);
                      if (nodo == null) {
                        yyerror("(sem) var <" + $1 + "> nao declarada"); 
                        $$ = Tp_ERRO;    
                      }           
                      else
                        $$ = nodo.getTipo();
                   }
  | num            {  $$ = Tp_INT; }
  | FuncCall
  ;

%%

  private Yylex lexer;

  private TabSimb ts;

  public static TS_entry Tp_INT =  new TS_entry("int", null, ClasseID.TipoBase);
  public static TS_entry Tp_DOUBLE = new TS_entry("double", null, ClasseID.TipoBase);
  public static TS_entry Tp_BOOL = new TS_entry("bool", null,  ClasseID.TipoBase);
  public static TS_entry Tp_ERRO = new TS_entry("_erro_", null,  ClasseID.TipoBase);
  
  public static final int ATRIB = 1600;

  private ClasseID currClass;
  private TS_entry currentType;

  private int yylex () {
    int yyl_return = -1;
    try {
      yylval = new ParserVal(0);
      yyl_return = lexer.yylex();
    }
    catch (IOException e) {
      System.err.println("IO error :"+e.getMessage());
    }
    return yyl_return;
  }

  public void yyerror (String error) {
    System.err.println ("Error: " + error);
  }

  public Parser(Reader r) {
    lexer = new Yylex(r, this);

    ts = new TabSimb();

    ts.insert(Tp_ERRO);
    ts.insert(Tp_INT);
    ts.insert(Tp_DOUBLE);
    ts.insert(Tp_BOOL);
  }

  static boolean interactive;

  public void setDebug(boolean debug) {
    yydebug = debug;
  }

  public void listarTS() { ts.listar(); }

  public static void main(String args[]) throws IOException {
    System.out.println("");

    Parser yyparser;
    if (args.length > 0) {
      // parse a file
      yyparser = new Parser(new FileReader(args[0]));
    }
    else {System.out.print("> ");
      interactive = true;
	    yyparser = new Parser(new InputStreamReader(System.in));
    }

    yyparser.yyparse();

    yyparser.listarTS();

  //  if (interactive) {
      System.out.println();
      System.out.println("done!");
  //  }
  }

  TS_entry validaTipo(int operador, TS_entry A, TS_entry B) {  
    switch (operador) {
      case ATRIB:
        if ((A == Tp_INT && B == Tp_INT)
          || ((A == Tp_DOUBLE && (B == Tp_INT || B == Tp_DOUBLE))) 
          || ((A == Tp_BOOL && B == Tp_BOOL)) 
          || (A == B))
          return A;
        else
          yyerror("(sem) tipos incomp. para atribuicao: "+ A.getTipoStr() + " = "+B.getTipoStr());
        break;
      case '+':
      case '-':
      case '*':
      case '/':
        if (A == Tp_INT && B == Tp_INT)
          return Tp_INT;
        else if ((A == Tp_DOUBLE && (B == Tp_INT || B == Tp_DOUBLE))
          || (B == Tp_DOUBLE && (A == Tp_INT || A == Tp_DOUBLE))) 
          return Tp_DOUBLE;     
        else
          yyerror("(sem) tipos incomp. para soma: "+ A.getTipoStr() + " : "+B.getTipoStr());
        break;
      case EQ:
      case NEQ:
      case GT:
      case LT:
      case LE:
      case GE:
        if ((A == Tp_INT || A == Tp_DOUBLE) && (B == Tp_INT || B == Tp_DOUBLE))
          return Tp_BOOL;
        else
          yyerror("(sem) tipos incomp. para op relacional: "+ A.getTipoStr() + " : "+B.getTipoStr());
        break;
      case AND:
      case OR:
        if (A == Tp_BOOL && B == Tp_BOOL)
          return Tp_BOOL;
        else
          yyerror("(sem) tipos incomp. para op lógica: "+ A.getTipoStr() + " : "+B.getTipoStr());
        break;
    }
    return Tp_ERRO; 
  }

  TS_entry validaTipo(int operador, TS_entry A) {  
    switch (operador) {
      case NOT:
        if (A == Tp_BOOL)
          return Tp_BOOL;
        else
          yyerror("(sem) tipos incomp. para op lógica: "+ A.getTipoStr());
        break;
    }
    return Tp_ERRO; 
  }
