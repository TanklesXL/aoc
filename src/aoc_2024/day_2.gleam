import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> List(List(Int)) {
  use line <- list.map(string.split(input, "\n"))
  use item <- list.map(string.split(line, " "))
  let assert Ok(i) = int.parse(item)
  i
}

type Direction {
  Increasing
  Decreasing
  Start
}

fn is_safe(line: List(Int)) -> Bool {
  line
  |> list.window_by_2
  |> list.try_fold(Start, fn(safety, pair) {
    let #(left, right) = pair
    let diff = right - left
    case safety {
      Start | Increasing if diff >= 1 && diff <= 3 -> Ok(Increasing)
      Start | Decreasing if diff <= -1 && diff >= -3 -> Ok(Decreasing)
      _ -> Error(Nil)
    }
  })
  |> result.is_ok
}

pub fn pt_1(input: List(List(Int))) {
  list.count(input, is_safe)
}

pub fn pt_2(input: List(List(Int))) {
  list.count(input, fn(line) {
    list.any(list.combinations(line, list.length(line) - 1), is_safe)
  })
}
