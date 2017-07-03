open Simple

let out chan s = 
  output_string chan s ;
  output_string chan "\n"

let _ = 
  let verbose = ref false in
  let debug = ref false in
  let input_chan = ref stdin in
  let output_chan = ref stdout in
  let options = [
    "-v", Arg.Set verbose, "Verbose mode";
    "-d", Arg.Set verbose, "Debug mode";
    "-i", Arg.String (fun s -> input_chan := open_in s), "Input file" ;
    "-o", Arg.String (fun s -> output_chan := open_out s), "Output file" ;
  ] in
    Arg.parse options (fun x -> ()) "Simple 1.0" ;
  let lexbuf = Lexing.from_channel !input_chan in
  let t = Parser.start Lexer.token lexbuf in
  let x1 = (dterm_of_term Env.empty t) in
  let x2 = (interpret_dterm [] x1) in
  let x3 = (value_of_dvalue [] x2) in
  if !verbose then out !output_chan 
    ((string_of_term t) ^ " : " ^ (string_of_type (fst (oTYPE [] t)))) ;
  if !debug then out !output_chan (string_of_dterm x1) ;
  if !debug then out !output_chan (string_of_dvalue x2) ;
  if !verbose then output_string !output_chan "=> " ;
  out !output_chan (string_of_value x3)
