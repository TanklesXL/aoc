import gleam/int
import gleam/string
import gleam/list

const sum = 2020

pub fn parse(input: String) -> List(Int) {
  let assert Ok(input) =
    input
    |> string.split("\n")
    |> list.try_map(int.parse)
  input
}

pub fn pt_1(input: List(Int)) -> Int {
  let assert Ok(#(a, b)) =
    input
    |> list.combination_pairs()
    |> list.find(fn(pair) {
      let #(a, b) = pair
      a + b == sum
    })

  a * b
}

pub fn pt_2(input: List(Int)) -> Int {
  let assert Ok(#(a, b, c)) =
    input
    |> list.combinations(by: 3)
    |> list.find_map(fn(triplet) {
      let assert [a, b, c] = triplet
      case a + b + c == sum {
        True -> Ok(#(a, b, c))
        False -> Error(Nil)
      }
    })

  a * b * c
}
