import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn parse(input: String) -> List(List(Set(String))) {
  use s <- list.map(string.split(input, "\n\n"))
  use s <- list.map(string.split(s, "\n"))
  s
  |> string.to_graphemes()
  |> set.from_list()
}

pub fn pt_1(input: List(List(Set(String)))) -> Int {
  process(input, set.union)
}

pub fn pt_2(input: List(List(Set(String)))) -> Int {
  process(input, set.intersection)
}

fn process(
  input: List(List(Set(String))),
  comparator: fn(Set(String), Set(String)) -> Set(String),
) -> Int {
  input
  |> list.map(set_compare(_, comparator))
  |> list.map(set.size)
  |> int.sum()
}

fn set_compare(
  sets: List(Set(a)),
  comparator: fn(Set(a), Set(a)) -> Set(a),
) -> Set(a) {
  case sets {
    [sets] -> sets
    [h, ..t] -> comparator(h, set_compare(t, comparator))
    _ -> panic
  }
}
