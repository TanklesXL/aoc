import gleam/string
import gleam/list
import gleam/int
import gleam/function

pub fn parse(input: String) -> List(List(Int)) {
  let assert Ok(input) =
    input
    |> string.split("\n\n")
    |> list.try_map(
      function.compose(string.split(_, "\n"), list.try_map(_, int.parse)),
    )
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
