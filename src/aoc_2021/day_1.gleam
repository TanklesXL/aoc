import gleam/list
import gleam/int
import gleam/string

fn process_input(s: String) -> List(Int) {
  let assert Ok(nums) =
    s
    |> string.split("\n")
    |> list.try_map(int.parse)

  nums
}

fn do_pt_1(l: List(Int)) -> Int {
  l
  |> list.window_by_2()
  |> list.fold(0, fn(acc: Int, pair: #(Int, Int)) {
    case pair.1 - pair.0 > 0 {
      True -> acc + 1
      False -> acc
    }
  })
}

pub fn pt_1(input: String) -> Int {
  input
  |> process_input
  |> do_pt_1
}

pub fn pt_2(input: String) -> Int {
  input
  |> process_input
  |> list.window(by: 3)
  |> list.map(int.sum)
  |> do_pt_1()
}
