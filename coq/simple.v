Require Import Coq.Strings.String.

Inductive expression :=
  | Integer: nat -> expression
  | Var: string -> expression
  | Add: expression -> expression -> expression
  | Lambda: string -> expression -> expression
  | Let: string -> expression -> expression -> expression
  | App: expression -> expression -> expression.


