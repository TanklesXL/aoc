import gleam/int
import gleam/list
import gleam/string
import tote/bag

pub fn parse(input: String) -> #(List(Int), List(Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert Ok(#(a, b)) = string.split_once(line, "   ")
    let assert Ok(left) = int.parse(a)
    let assert Ok(right) = int.parse(b)
    #(left, right)
  })
  |> list.unzip
}

pub fn pt_1(input: #(List(Int), List(Int))) -> Int {
  let sort_ints = list.sort(_, int.compare)
  let sorted = list.zip(sort_ints(input.0), sort_ints(input.1))
  use acc, #(left, right) <- list.fold(sorted, 0)
  acc + int.absolute_value(left - right)
}

pub fn pt_2(input: #(List(Int), List(Int))) {
  let counts = bag.from_list(input.1)
  use acc, id <- list.fold(input.0, 0)
  acc + { id * bag.copies(counts, id) }
}
