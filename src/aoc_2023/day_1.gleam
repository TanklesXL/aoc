import gleam/bool
import gleam/int
import gleam/list
import gleam/string

fn digits_to_calibration(l: List(Int)) -> Int {
  let #(first, last) = case l {
    [] -> panic as "each line must contain at least one digit"
    [x] -> #(x, x)
    [first, ..] -> {
      let assert Ok(last) = list.last(l)
      #(first, last)
    }
  }

  10 * first + last
}

fn process(input: String, pre_process: fn(String) -> List(String)) {
  input
  |> string.split("\n")
  |> list.fold(0, fn(acc, line) {
    acc
    + {
      line
      |> pre_process
      |> list.filter_map(int.parse)
      |> digits_to_calibration
    }
  })
}

fn words(s: String, acc: List(String)) -> List(String) {
  use <- bool.guard(s == "", list.reverse(acc))
  let char = case s {
    "one" <> _ -> "1"
    "two" <> _ -> "2"
    "three" <> _ -> "3"
    "four" <> _ -> "4"
    "five" <> _ -> "5"
    "six" <> _ -> "6"
    "seven" <> _ -> "7"
    "eight" <> _ -> "8"
    "nine" <> _ -> "9"
    _ -> {
      let assert Ok(first) = string.first(s)
      first
    }
  }
  words(string.drop_left(s, 1), [char, ..acc])
}

pub fn pt_1(input: String) {
  process(input, string.to_graphemes)
}

pub fn pt_2(input: String) {
  process(input, words(_, []))
}
