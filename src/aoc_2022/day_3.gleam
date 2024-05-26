import gleam/list
import gleam/set
import gleam/string

fn priority(grapheme: String) {
  case <<grapheme:utf8>> {
    // lowercase a (ascii 97) to z (ascii 122) is priority 1 to 26
    <<char:int>> if char >= 97 -> char - 96
    // uppercase A (ascii 65) to Z (ascii 90) is priority 27 to 52
    <<char:int>> -> char - 38
    _ -> panic
  }
}

pub fn pt_1(input: String) {
  // split into lines
  let lines =
    input
    |> string.split("\n")
    |> list.map(string.to_graphemes)
  // collect for all lines
  use acc, line <- list.fold(lines, 0)
  // split characters into two halves
  let #(a, b) = list.split(line, list.length(line) / 2)
  // create sets from each
  let a = set.from_list(a)
  let b = set.from_list(b)
  // gather common chars
  let shared = set.intersection(a, b)
  use acc, grapheme <- set.fold(shared, acc)
  acc + priority(grapheme)
}

pub fn pt_2(input: String) {
  // split into lines
  let assert Ok(groups) =
    input
    |> string.split("\n")
    // get character set for each line
    |> list.map(fn(s) {
      s
      |> string.to_graphemes
      |> set.from_list
    })
    // split into chunks of 3
    |> list.sized_chunk(3)
    // set intersection of each group
    |> list.try_map(list.reduce(_, set.intersection))

  // for all chunks add priority to sum
  use acc, shared <- list.fold(groups, 0)
  use acc, grapheme <- set.fold(shared, acc)
  acc + priority(grapheme)
}
