{
  open Parser
}
rule token = parse
  | eof { EOF }
  | [' ' '\t' '\n'] { token lexbuf }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | "lambda" { LAMBDA }
  | "let" { LET }
  | ['0'-'9']+ { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | ['a'-'z']+ { IDENT (Lexing.lexeme lexbuf) }
