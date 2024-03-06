import gleam/string
import gleam/list
import gleam/int
import gleam/result

// pair helpers
pub fn pair_try_map(p: #(a, a), f: fn(a) -> Result(b, c)) -> Result(#(b, b), c) {
  use a <- result.try(f(p.0))
  use b <- result.try(f(p.1))
  Ok(#(a, b))
}

pub fn pair_apply(p: #(a, b), f: fn(a, b) -> c) -> c {
  f(p.0, p.1)
}

// parse input
pub fn parse(input: String) -> List(#(#(Int, Int), #(Int, Int))) {
  let assert Ok(ranges) = {
    use line <- list.try_map(string.split(input, "\n"))
    line
    |> string.split_once(",")
    |> result.then(pair_try_map(_, string.split_once(_, "-")))
    |> result.then(pair_try_map(_, pair_try_map(_, int.parse)))
  }
  ranges
}

fn solve(
  input: List(#(#(Int, Int), #(Int, Int))),
  f: fn(#(Int, Int), #(Int, Int)) -> Bool,
) {
  input
  |> list.filter(pair_apply(_, f))
  |> list.length
}

fn complete_overlap(a: #(Int, Int), b: #(Int, Int)) -> Bool {
  a.0 <= b.0 && a.1 >= b.1 || b.0 <= a.0 && b.1 >= a.1
}

pub fn pt_1(input: List(#(#(Int, Int), #(Int, Int)))) {
  solve(input, complete_overlap)
}

fn partial_overlap(a: #(Int, Int), b: #(Int, Int)) -> Bool {
  a.0 <= b.0 && b.0 <= a.1 || b.0 <= a.0 && a.0 <= b.1
}

pub fn pt_2(input: List(#(#(Int, Int), #(Int, Int)))) {
  solve(input, partial_overlap)
}
