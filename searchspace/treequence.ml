type 'a t =
| Empty
| Single of 'a
| Append of {sz: int; lt: 'a t; rt: 'a t }

let size = function
| Empty -> 0
| Single _ -> 1
| Append {sz;_} -> sz

let empty = Empty

let is_empty t = size t = 0

let singleton x = Single x

let append xs ys = match xs, ys with
| Empty, ys -> ys
| xs, Empty -> xs
| _ -> Append{sz=size xs + size ys; lt=xs; rt=ys}

let push x xs = append (singleton x) xs

let push_end x xs = append xs (singleton x)

let rec pop = function
| Empty -> None
| Single x -> Some (x, Empty)
| Append {lt=Empty;rt;_} -> pop rt
| Append {lt=Single x; rt; _} -> Some(x,rt)
| Append {lt=Append{lt=a;rt=b;_};rt=c; _} ->
    pop (append a (append b c))

let rec pop_end = function
| Empty -> None
| Single x -> Some (x, Empty)
| Append {lt; rt=Empty; _} -> pop lt
| Append {lt; rt=Single x; _} -> Some(x, lt)
| Append {lt=a; rt=Append{lt=b; rt=c; _}; _} ->
    pop_end (append (append a b) c)

let rec map f = function
| Empty -> Empty
| Single x -> Single (f x)
| Append {sz; lt; rt} -> Append {sz; lt=map f lt; rt=map f rt}

let rec to_string str = function
| Empty -> "nil"
| Single x -> str x
| Append{lt;rt;_} -> "[" ^ to_string str lt ^ " " ^ to_string str rt ^ "]"

let%expect_test "pushes and pops" =
  let stack = empty
    |> push 1
    |> push 2
    |> push 3
    |> push 4
    |> push 5 in
  Printf.printf "stack: %s\n" (to_string Int.to_string stack);
  let rec pop_all stack =
  pop stack |> (function
  | Some (top, rest) ->
      Printf.printf "Popped: %d Rest: %s\n" top (to_string Int.to_string rest);
      pop_all rest
  | None -> Printf.printf "===end==="
  )
  in pop_all stack
  ;[%expect{|
    stack: [5 [4 [3 [2 1]]]]
    Popped: 5 Rest: [4 [3 [2 1]]]
    Popped: 4 Rest: [3 [2 1]]
    Popped: 3 Rest: [2 1]
    Popped: 2 Rest: 1
    Popped: 1 Rest: nil
    ===end=== |}]

let%expect_test "use as a queue" =
  let stack = empty
    |> push 1
    |> push 2
    |> push 3
    |> push 4
    |> push 5 in
  Printf.printf "stack: %s\n" (to_string Int.to_string stack);
  let rec pop_all stack =
  pop_end stack |> (function
  | Some (top, rest) ->
      Printf.printf "Popped: %d Rest: %s\n" top (to_string Int.to_string rest);
      pop_all rest
  | None -> Printf.printf "===end==="
  )
  in pop_all stack
  ;[%expect{|
    stack: [5 [4 [3 [2 1]]]]
    Popped: 1 Rest: [[[5 4] 3] 2]
    Popped: 2 Rest: [[5 4] 3]
    Popped: 3 Rest: [5 4]
    Popped: 4 Rest: 5
    Popped: 5 Rest: nil
    ===end=== |}]
