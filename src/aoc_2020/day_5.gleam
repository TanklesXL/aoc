import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> List(Int) {
  input
  |> string.split("\n")
  |> list.map(calculate_seat_id)
  |> list.sort(int.compare)
}

pub fn pt_1(input: List(Int)) -> Int {
  list.last(input)
  |> result.unwrap(0)
}

pub fn pt_2(input: List(Int)) -> Int {
  input
  |> find_missing()
}

fn calculate_seat_id(ticket: String) -> Int {
  ticket
  |> string.to_graphemes()
  |> list.reverse()
  |> list.index_map(fn(val, i) {
    case val {
      "L" | "F" -> 0
      "R" | "B" -> int.bitwise_shift_left(1, i)
      _ -> panic
    }
  })
  |> int.sum()
}

fn find_missing(seats: List(Int)) -> Int {
  let assert [l, r, ..rest] = seats
  case r - l {
    2 -> r - 1
    _ -> find_missing([r, ..rest])
  }
}
