%token<int> INT
%token<string> IDENT
%token LAMBDA LET LPAREN RPAREN EOF
%start start
%type <Simple.term> start

%%

start: 
| term EOF { $1 }

term:
| INT { Simple.Integer ($1) }
| IDENT { Simple.Var ($1) }
| LPAREN term term RPAREN { Simple.App ($2, $3) }
| LPAREN LAMBDA LPAREN IDENT RPAREN term RPAREN { Simple.Lambda ($4, $6) }
| LPAREN LET LPAREN IDENT term RPAREN term RPAREN { Simple.Let ($4, $5, $7) }
