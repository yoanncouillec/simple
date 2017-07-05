type expression =
  | Integer of int
  | Var of string
  | Add of expression * expression
  | Lambda of string * expression
  | Let of string * expression * expression
  | App of expression * expression

and value = 
  | VInt of int
  | VClosure of string * expression * env

and env = (string * value) list

let rec let_remover = function
  | Let (ident, e1, e2) -> App(Lambda(ident, let_remover e2), let_remover e1)
  | _ as e -> e

let rec lookup env ident = 
  match env with
  | (ident',value)::rest -> if ident = ident' then value else lookup rest ident
  | [] -> failwith "lookup: no such binding"

let rec eval env = function
  | Integer n -> VInt n
  | Var ident -> lookup env ident
  | Add (e1, e2) ->
     (match (eval env e1, eval env e2) with
      | (VInt n1, VInt n2) -> VInt (n1 + n2)
      | _ -> failwith "eval: integers excepted")
  | Lambda (s, e) -> VClosure (s, e, env)
  | Let _ -> failwith "eval: let Not implemented"
  | App (e1, e2) ->
     (match eval env e1 with
      | VClosure (ident, body, env) -> eval ((ident, eval env e2)::env) body
      | _ -> failwith "eval: closure expected")

let rec string_of_expression = function
  | Integer n -> string_of_int n
  | Var s -> s
  | Add (e1, e2) -> "(+ " ^ (string_of_expression e1) ^ " " ^ 
      (string_of_expression e2) ^ ")"
  | Lambda (s, e) -> "(lambda (" ^ s ^ ") " ^ (string_of_expression e) ^ ")"
  | Let (s, e1, e2) -> "(let (" ^ s ^ " " ^ (string_of_expression e1) ^ ") " ^ (string_of_expression e2) ^ ")"
  | App (e1, e2) -> "("^(string_of_expression e1) ^ " " ^ (string_of_expression e2)^")"

let rec string_of_value = function
  | VInt n -> string_of_int n
  | VClosure (ident, body, env) -> "(lambda ("^ident^") "^(string_of_expression body)^")"

and string_of_values = function
  | [] -> ""
  | value :: rest ->
      (string_of_value value) ^ " " ^ (string_of_values rest)
