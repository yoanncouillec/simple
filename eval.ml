open Simple
let rec string_of_channel channel accu = 
  try
    let line = input_line channel in
    string_of_channel channel (accu^line)
  with
  | End_of_file -> accu

let _ = 
  let lexbuf = Lexing.from_string (string_of_channel stdin "") in
  let term = Parser.start Lexer.token lexbuf in
  let dterm = dterm_of_term Env.empty term in
  let value = interpret_dterm [] dterm in
  print_string (string_of_term term) ;
  print_endline (" : "^string_of_type (fst(oTYPE [] term))) ;
  print_endline("=> "^string_of_dvalue value) ;
  print_newline();

