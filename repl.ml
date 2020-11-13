open Simple

let _ = 
  print_endline "                                     ";
  print_endline "(((((((((((((((((((((((((((((((((((((";
  print_endline "                                     ";
  print_endline "            Simple Repl              ";
  print_endline "                                     ";
  print_endline ")))))))))))))))))))))))))))))))))))))";
  try
    while true do
      print_string "\n# " ; 
      flush stdout ;
      let lexbuf = Lexing.from_string (read_line ()) in
      try
        let term = Parser.start Lexer.token lexbuf in
	let env = [] in
        let value = interpret_term env term in
        print_string "= " ; print_string (string_of_value value) ; print_newline ()
      with 
      | Failure m -> print_string "! " ; print_endline m
      | Parsing.Parse_error -> print_endline "! Parse error"
    done
  with End_of_file ->
    print_newline()
