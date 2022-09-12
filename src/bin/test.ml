(* file: test.ml
   author: Bob Muller

   CSCI 3366 Programming Languages

   This is a test harness for testing the parser for the
   mini-language Mercury.

 ******************************************************
   Some simple hand-made ASTs for testing the parser.
*)
let two   = Ast.Literal 2
let three = Ast.Literal 3
let four  = Ast.Literal 4
let five  = Ast.Literal 5

let plus = Symbol.fromString "+"
let times = Symbol.fromString "*"
let minus = Symbol.fromString "-"

let fourMinus =
  Ast.App { rator = minus
          ; rands = [ Ast.App { rator = minus
                              ; rands = [four; two]
                              }
                    ; two
                    ]
          }
let threeTimesFour =
  Ast.App { rator = times
          ; rands = [three; four]}
let twoPlus =
  Ast.App { rator = plus
          ; rands = [two; threeTimesFour]}
let timesFive =
  Ast.App { rator = times
          ; rands = [twoPlus; five]}

let makeTest input expected =
  (fun () ->
     let tokens = Tokenizer.tokenizer input in
     let ast = Parser.parser tokens
     in
     Ast.equal ast expected)

let makeFailTest input =
  (fun () ->
     let tokens = Tokenizer.tokenizer input
     in
     try
       let _ = Parser.parser tokens in false
     with
       Failure _-> true)

(* Succeeding Tests
*)
let input1 = Tokenizer.Test "2 + 3 * 4"
let input2 = Tokenizer.Test "(2 + 3 * 4) * 5"
let input3 = Tokenizer.Test "((((3))))"
let input4 = Tokenizer.Test "4 - 2 - 2"

(* Failing Tests --- parser should failwith
*)
let input5 = Tokenizer.Test "(2 + 3 * 4 * 5"
let input6 = Tokenizer.Test "-3"
let input7 = Tokenizer.Test "()"
let input8 = Tokenizer.Test "2 % 4)"

let expected1 = twoPlus
let test1 = makeTest input1 expected1

let expected2 = timesFive
let test2 = makeTest input2 expected2

let expected3 = three
let test3 = makeTest input3 expected3

let expected4 = fourMinus
let test4 = makeTest input4 expected4

let test5 = makeFailTest input5
let test6 = makeFailTest input6
let test7 = makeFailTest input7
let test8 = makeFailTest input8

let run () =
  let tests = [ ("test1: precedence", test1)
              ; ("test2", test2)
              ; ("test3: nested parens", test3)
              ; ("test4: associativity", test4)
              ; ("test5", test5)
              ; ("test6", test6)
              ; ("test7", test7)
              ; ("test8", test8)
              ]
  in
  List.iter (fun (name, test) -> Lib.run_test name test) tests
