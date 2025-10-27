import gleam/deque.{type Deque}
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

fn solve(input: String, window_size: Int) -> Int {
  let #(window, letters) =
    input
    |> string.to_graphemes
    |> build_window(window_size)

  window_size
  + {
    do_deque_window(letters, window, window_size)
    |> pair.first()
  }
}

fn build_window(
  letters: List(String),
  window_size: Int,
) -> #(Deque(String), List(String)) {
  use acc <- repeatedly(#(deque.new(), letters), window_size)
  let assert [first, ..rest] = acc.1
  #(deque.push_back(acc.0, first), rest)
}

fn repeatedly(with start: a, num times: Int, do f: fn(a) -> a) -> a {
  case times {
    0 -> start
    _ -> repeatedly(f(start), times - 1, f)
  }
}

fn do_deque_window(letters: List(String), window: Deque(String), size: Int) {
  use acc, elem <- list.fold_until(letters, #(0, window))
  let #(index, window) = acc
  case
    size
    == window
    |> deque.to_list
    |> list.unique
    |> list.length
  {
    True -> list.Stop(acc)
    False -> {
      let assert Ok(window) =
        window
        |> deque.pop_front()
        |> result.map(pair.second)
        |> result.map(deque.push_back(_, elem))
      list.Continue(#(index + 1, window))
    }
  }
}

pub fn pt_1(input: String) {
  solve(input, 4)
}

pub fn pt_2(input: String) {
  solve(input, 14)
}
