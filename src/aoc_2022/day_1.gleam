import gleam/function
import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(List(Int)) {
  let assert Ok(input) =
    input
    |> string.split("\n\n")
    |> list.try_map(fn(s) {
      s
      |> string.split("\n")
      |> list.try_map(int.parse)
    })
  input
}

pub fn pt_1(input: List(List(Int))) {
  input
  |> calories(top: 1)
}

pub fn pt_2(input: List(List(Int))) {
  input
  |> calories(top: 3)
}

fn calories(food: List(List(Int)), top count: Int) -> Int {
  food
  |> list.map(int.sum)
  |> list.sort(function.flip(int.compare))
  |> list.take(count)
  |> int.sum
}
