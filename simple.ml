open List

type term = 
| Integer of int
| Var of string
| Lambda of string * term
| App of term * term
| Let of string * term * term

type value =
| VInteger of int
| VClosure of string * term * env
and env = (string * value) list

exception TermNoClosure of string

let rec string_of_term = function
  | Integer n -> string_of_int n
  | Var s -> s
  | Lambda (s, e) -> "(lambda (" ^ s ^ ") " ^ (string_of_term e) ^ ")"
  | App (e1, e2) -> "(" ^ (string_of_term e1) ^ " " ^ (string_of_term e2) ^ ")"
  | Let (s, t1, t2) -> "(let (" ^ s ^ " " ^ (string_of_term t1) ^ ") " ^ (string_of_term t2)

let rec string_of_value = function
  | VInteger n -> string_of_int n
  | VClosure (s, e, env) -> "(lambda (" ^ s ^ ") " ^ (string_of_term e) ^ ")" ^ (string_of_env env)

and string_of_env_aux = function
  | [] -> ""
  | (s, v) :: [] -> s ^ " -> " ^ (string_of_value v)
  | (s, v) :: rest -> s ^ " -> " ^ (string_of_value v) ^ ", " ^ (string_of_env_aux rest)

and string_of_env e = "[" ^ (string_of_env_aux e) ^ "]"

let rec interpret_term env = function
  | Integer n -> VInteger n
  | Var s -> assoc s env
  | Lambda (s, e) -> VClosure (s, e, env)
  | App (e1, e2) ->
    begin
      match interpret_term env e1 with
      | VClosure (s, e3, env') -> 
	interpret_term ((s, (interpret_term env e2)) :: env') e3
      | _ -> raise (TermNoClosure (string_of_term e1))
    end
  | Let (s, t1, t2) ->
    let v1 = interpret_term env t1 in
    interpret_term ((s, v1) :: env) t2

type dterm = 
  | DInt of int
  | DVar of int
  | DAbs of dterm
  | DApp of dterm * dterm

type dvalue =
| DVInteger of int
| DVClosure of dterm * denv
and denv = (int * dvalue) list

exception DtermNoClosure of string

let rec string_of_dterm = function
  | DInt n -> string_of_int n
  | DVar n -> string_of_int n
  | DAbs t1 -> "(lambda () " ^ (string_of_dterm t1) ^ ")"
  | DApp (t1, t2) -> "(" ^ (string_of_dterm t1) ^ " " ^ (string_of_dterm t2) ^ ")"

let rec string_of_dvalue = function
  | DVInteger n -> string_of_int n
  | DVClosure (t, e) -> "(lambda () " ^ (string_of_dterm t) ^ ")" ^ (string_of_denv e)

and string_of_denv_aux = function
  | [] -> ""
  | (n, v) :: [] -> (string_of_int n) ^ " -> " ^ (string_of_dvalue v)
  | (n, v) :: rest -> (string_of_int n) ^ " -> " ^ (string_of_dvalue v) ^ ", " ^ (string_of_denv_aux rest)

and string_of_denv e = "[" ^ (string_of_denv_aux e) ^ "]"

module Env = Map.Make(struct type t = string let compare = String.compare end)

let rec dterm_of_term env = function
  | Integer n -> DInt n
  | Var s -> (DVar (Env.find s env))
  | Lambda (s, t) -> DAbs (dterm_of_term (Env.add s 0 (Env.map succ env)) t)
  | App (t1, t2) -> DApp (dterm_of_term env t1, dterm_of_term env t2)
  | Let (s, t1, t2) -> 
    let ne = (Env.add s 0 (Env.map succ env)) in
    DApp (dterm_of_term env (Lambda (s, t2)), dterm_of_term ne t1)
      
let inc_env env = 
  List.map (function (a,b) -> (a+1, b)) env

let rec interpret_dterm env = function
  | DInt n -> DVInteger n
  | DVar n -> assoc n env
  | DAbs t -> DVClosure (t, env)
  | DApp (t1, t2) -> 
    match interpret_dterm env t1 with
    | DVClosure (t3, e) -> 
      interpret_dterm (((0, (interpret_dterm env t2)) :: (inc_env e))) t3
    | _ -> raise (DtermNoClosure (string_of_dterm t1))

let c = ref 0
let reset () = c := 0
let gensym s = incr c ; s ^ (string_of_int !c)

let rec term_of_dterm env = function
  | DInt n -> Integer n
  | DVar n -> Var (assoc n env)
  | DAbs t -> 
    let s = gensym "x" in
    Lambda (s, term_of_dterm ((0, s) :: (inc_env env)) t)
  | DApp (t1, t2) -> 
    App (term_of_dterm env t1, term_of_dterm env t2)
      
let rec env_of_denv env = function
  | [] -> []
  | (n, dv) :: rest -> 
    (gensym "x", value_of_dvalue env dv) :: (env_of_denv env rest)
      
and value_of_dvalue env = function
  | DVInteger n -> VInteger n
  | DVClosure (t, e) -> 
    let s = gensym "x" in
    let ne = (0, s) :: (inc_env env) in
    VClosure (s, term_of_dterm ne t, env_of_denv ne e)

type oType = 
| TInt
| TVar of string 
| TArrow of oType * oType

let substitute s t = 
  let rec sub_rec = function
    | TInt -> TInt
    | (TVar a) as alpha -> (try List.assoc a s with Not_found -> alpha)
    | TArrow(oT1,oT2) -> TArrow (sub_rec oT1, sub_rec oT2)
  in sub_rec t
  
let compsubst s t = 
  (List.map (function (a,oT) -> (a,substitute s oT)) t) @ s;;

let occur v t = 
  let rec occ_rec t = match t with 
    | TInt -> false
    | TVar b -> b=v
    | TArrow(oT1,oT2) -> occ_rec oT1 or occ_rec oT2
  in occ_rec t

let rec unify c = match c with 
  | (TVar a), oT -> 
      if oT = TVar a then [] 
      else if occur a oT then raise (Failure "unify")
           else [a,oT]
  | oT,TVar a -> 
      if occur a oT then raise (Failure "unify")
      else [a,oT]
  | TArrow(oS1,oS2), TArrow(oT1,oT2) -> 
      let s=unify(oS1,oT1)  in
          compsubst   (unify(substitute s oS2,
                             substitute s oT2)) s



let rec type_of_term env term =
  match term with
  | Integer n -> TInt, []
  | Var s -> List.assoc s env , []
  | Lambda (s,body) -> 
    let name = gensym "a" in
    let (tbody,env') = type_of_term ((s,TVar name)::env) body in
    TArrow ((try
               List.assoc name env'
             with _ ->  TVar name), 
            tbody), env'
  |  App(e1,e2) -> 
    let (te1,s) = type_of_term env e1 in
    let (te2,t) =
      type_of_term
        (List.map
           (function (x,phi) -> (x,substitute s phi))
           env)
        e2   in
    let name = gensym "a" in 
    let u = unify (substitute t te1, TArrow(te2,TVar name))  in
    (try List.assoc name u with _ ->  TVar name),
    compsubst u (compsubst t s)
      
let string_of_type t = 
  let rec ptype t = match t with 
    | TInt -> "int"
    | TVar x -> x
    | TArrow (x,y) -> "(" ^ (ptype x) ^ " -> " ^ (ptype y) ^ ")"
  in 
    ptype t
