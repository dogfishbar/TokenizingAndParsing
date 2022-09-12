(* file: parser.ml
  author: Bob Muller

  CS3366 Programming Languages

   This code implements a recursive descent parser for the mini-PL
   Mercury --- the simplest programming language with just integers.

  Terms:

  E ::= E + T | E - T | T
  T ::= T * F | T / F | T % F | F
  F ::= Integer | ( E )

   Rewriting to remove left-recursion, we get:

  Terms:

  E  ::= T E'
  E' ::= + T E' | - T E' | empty
  T  ::= F T'
  T' ::= * F T' | / F T' | % F T' | empty
  F  ::= Integer | ( E )

   Debugging
*)
let dbg = Debug.out "parser"

(* Symbols for built-in operators *)
let plus  = Symbol.fromString "+"
let minus = Symbol.fromString "-"
let times = Symbol.fromString "*"
let div   = Symbol.fromString "/"
let md    = Symbol.fromString "%"

(* Parsing Expressions

  E  ::= T E'
  E' ::= + T E' | - T E' | empty
  T  ::= F T'
  T' ::= * F T' | / F T' | % F T' | empty
  F  ::= Integer | ( E )
*)
let rec expression tokens =                       (* E  ::= T E' *)
  let (t1Ast, tokens) = term tokens
  in
  exprTail tokens t1Ast

and exprTail tokens t1Ast =           (* E' ::= + T E' | - T E' | empty *)
  match tokens with
  | Token.PLUS :: tokens ->
    let (t2Ast, tokens) = term tokens in
    let ast = Ast.App { rator = plus
                      ; rands = [t1Ast; t2Ast]
                      }
    in
    exprTail tokens ast

  | Token.MINUS :: tokens ->
    let (t2Ast, tokens) = term tokens in
    let ast = Ast.App { rator = minus
                      ; rands = [t1Ast; t2Ast]
                      }
    in
    exprTail tokens ast

  | _ -> (t1Ast, tokens)

and
  term tokens =                       (* T  ::= F T' *)
  let (t1Ast, tokens) = factor tokens
  in
  termTail tokens t1Ast

and
  termTail tokens t1Ast =         (* T' ::= * F T' | / F T' | % F T' | empty *)
  match tokens with
  | Token.TIMES :: tokens ->
    let (t2Ast, tokens) = factor tokens in
    let ast = Ast.App { rator = times
                      ; rands = [t1Ast; t2Ast]
                      }
    in
    termTail tokens ast

  | Token.DIV :: tokens ->
    let (t2Ast, tokens) = factor tokens in
    let ast = Ast.App { rator = div
                      ; rands = [t1Ast; t2Ast]
                      }
    in
    termTail tokens ast

  | Token.MOD :: tokens ->
    let (t2Ast, tokens) = factor tokens in
    let ast = Ast.App { rator = md
                      ; rands = [t1Ast; t2Ast]
                      }
    in
    termTail tokens ast

  | _ -> (t1Ast, tokens)

and
  factor tokens =                      (* F  ::= Integer | ( E ) *)
  match tokens with
  | (Token.INTEGER i) :: tokens  -> (Ast.i2i i, tokens)     (* Integer *)

  | Token.LPAR :: tokens ->
    let (expr, tokens) = expression tokens
    in
    (match tokens with
     | Token.RPAR :: tokens -> (expr, tokens)               (* ( E ) *)
     | _ -> failwith "( expr followed by neither , nor )")

  | _ -> failwith "factor: parsing factor, found bad input"

let parser tokens =
  dbg (Lib.fmt "tokens = %s" (Token.formatTokens tokens));
  match expression tokens with
  | (ast, []) -> ast
  | _ -> failwith "bad syntax, found a parse but there are leftover tokens."
