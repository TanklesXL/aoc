import gleam/int
import gleam/list
import gleam/string

pub fn parse(s: String) -> List(Int) {
  let assert Ok(nums) =
    s
    |> string.split("\n")
    |> list.try_map(int.parse)

  nums
}

pub fn pt_1(l: List(Int)) -> Int {
  use acc: Int, pair: #(Int, Int) <- list.fold(list.window_by_2(l), 0)
  case pair.1 - pair.0 > 0 {
    True -> acc + 1
    False -> acc
  }
}

pub fn pt_2(input: List(Int)) -> Int {
  input
  |> list.window(by: 3)
  |> list.map(int.sum)
  |> pt_1()
}
