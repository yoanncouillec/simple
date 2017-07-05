open Simple
let rec string_of_channel channel accu = 
  try
    let line = input_line channel in
    string_of_channel channel (accu^line)
  with
  | End_of_file -> accu

let _ = 
  let lexbuf = Lexing.from_string (string_of_channel stdin "") in
  let expression = Parser.start Lexer.token lexbuf in
  let env = [] in
  let value = eval env expression in
  print_string (string_of_value value) ; print_newline ()
