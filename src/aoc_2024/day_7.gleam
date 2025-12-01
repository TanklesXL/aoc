import aoc/shared
import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(#(Int, List(Int))) {
  use line <- list.map(string.split(input, "\n"))
  let assert Ok(#(test_val, args)) = string.split_once(line, ": ")
  let assert Ok(test_val) = int.parse(test_val)
  let assert Ok(vals) = list.try_map(string.split(args, " "), int.parse)
  #(test_val, vals)
}

pub fn pt_1(input: List(#(Int, List(Int)))) -> Int {
  use acc, #(test_val, args) <- list.fold(input, 0)
  let assert [first, ..rest] = args
  case do(rest, first, test_val, [int.add, int.multiply]) {
    True -> acc + test_val
    False -> acc
  }
}

pub fn pt_2(input: List(#(Int, List(Int)))) {
  use acc, #(test_val, args) <- list.fold(input, 0)
  let assert [first, ..rest] = args
  case do(rest, first, test_val, [int.add, int.multiply, concat]) {
    True -> acc + test_val
    False -> acc
  }
}

fn concat(front: Int, back: Int) -> Int {
  let assert Ok(front) = shared.digits(front, 10)
  let assert Ok(back) = shared.digits(back, 10)
  let assert Ok(smushed) = list.flatten([front, back]) |> shared.undigits(10)
  smushed
}

fn do(input, acc, test_val, ops) -> Bool {
  case input {
    [] -> acc == test_val
    [x, ..xs] -> list.any(ops, fn(op) { do(xs, op(acc, x), test_val, ops) })
  }
}
