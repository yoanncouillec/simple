type token =
  | INT of (int)
  | IDENT of (string)
  | LAMBDA
  | LET
  | LPAREN
  | RPAREN
  | EOF

open Parsing;;
let _ = parse_error;;
let yytransl_const = [|
  259 (* LAMBDA *);
  260 (* LET *);
  261 (* LPAREN *);
  262 (* RPAREN *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  257 (* INT *);
  258 (* IDENT *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\002\000\002\000\002\000\000\000"

let yylen = "\002\000\
\002\000\001\000\001\000\004\000\007\000\008\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\002\000\003\000\000\000\007\000\000\000\000\000\
\000\000\000\000\001\000\000\000\000\000\000\000\000\000\000\000\
\004\000\000\000\000\000\000\000\000\000\005\000\000\000\006\000"

let yydgoto = "\002\000\
\006\000\007\000"

let yysindex = "\001\000\
\013\255\000\000\000\000\000\000\005\255\000\000\003\000\252\254\
\255\254\013\255\000\000\010\255\015\255\014\255\016\255\013\255\
\000\000\013\255\017\255\018\255\013\255\000\000\019\255\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\251\255"

let yytablesize = 25
let yytable = "\010\000\
\012\000\001\000\011\000\013\000\014\000\003\000\004\000\008\000\
\009\000\005\000\019\000\015\000\020\000\003\000\004\000\023\000\
\016\000\005\000\000\000\017\000\000\000\018\000\021\000\022\000\
\024\000"

let yycheck = "\005\000\
\005\001\001\000\000\000\005\001\010\000\001\001\002\001\003\001\
\004\001\005\001\016\000\002\001\018\000\001\001\002\001\021\000\
\002\001\005\001\255\255\006\001\255\255\006\001\006\001\006\001\
\006\001"

let yynames_const = "\
  LAMBDA\000\
  LET\000\
  LPAREN\000\
  RPAREN\000\
  EOF\000\
  "

let yynames_block = "\
  INT\000\
  IDENT\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'term) in
    Obj.repr(
# 10 "parser.mly"
           ( _1 )
# 86 "parser.ml"
               : Simple.expression))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 13 "parser.mly"
      ( Simple.Integer (_1) )
# 93 "parser.ml"
               : 'term))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 14 "parser.mly"
        ( Simple.Var (_1) )
# 100 "parser.ml"
               : 'term))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'term) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'term) in
    Obj.repr(
# 15 "parser.mly"
                          ( Simple.App (_2, _3) )
# 108 "parser.ml"
               : 'term))
; (fun __caml_parser_env ->
    let _4 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : 'term) in
    Obj.repr(
# 16 "parser.mly"
                                                ( Simple.Lambda (_4, _6) )
# 116 "parser.ml"
               : 'term))
; (fun __caml_parser_env ->
    let _4 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _5 = (Parsing.peek_val __caml_parser_env 3 : 'term) in
    let _7 = (Parsing.peek_val __caml_parser_env 1 : 'term) in
    Obj.repr(
# 17 "parser.mly"
                                                  ( Simple.Let (_4, _5, _7) )
# 125 "parser.ml"
               : 'term))
(* Entry start *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let start (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Simple.expression)
