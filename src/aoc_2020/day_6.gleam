import gleam/int
import gleam/list
import gleam/string
import gleam/set.{type Set}

pub fn pt_1(input: String) -> Int {
  input
  |> pre_process()
  |> process(set.union)
}

pub fn pt_2(input: String) -> Int {
  input
  |> pre_process()
  |> process(set.intersection)
}

fn pre_process(input: String) -> List(List(Set(String))) {
  use s <- list.map(string.split(input, "\n\n"))
  use s <- list.map(string.split(s, "\n"))
  s
  |> string.to_graphemes()
  |> set.from_list()
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
