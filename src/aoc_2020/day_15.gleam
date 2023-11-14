import gleam/iterator
import gleam/map.{type Map}
import gleam/list
import gleam/pair
import gleam/option
import gleam/string
import gleam/int

const steps_1 = 2020

const steps_2 = 30_000_000

pub fn pt_1(input: String) -> Int {
  let assert Ok(input) =
    input
    |> string.split(",")
    |> list.try_map(int.parse)
  execute(input, steps_1)
}

pub fn pt_2(input: String) -> Int {
  let assert Ok(input) =
    input
    |> string.split(",")
    |> list.try_map(int.parse)
  execute(input, steps_2)
}

fn execute(input: List(Int), iterations: Int) -> Int {
  let starting = init(input)
  let assert Ok(last_inserted) = list.last(input)
  let starting_acc = #(last_inserted, starting)

  iterator.range(list.length(input) + 1, iterations)
  |> iterator.fold(starting_acc, speak)
  |> pair.first()
}

type Spoken {
  Never
  Once(first: Int)
  Multiple(last: Int, second_last: Int)
}

fn init(l: List(Int)) -> Map(Int, Spoken) {
  iterator.from_list(l)
  |> iterator.zip(iterator.range(1, list.length(l)))
  |> iterator.fold(map.new(), fn(acc, t) {
    let #(val, i) = t
    map.insert(acc, val, Once(i))
  })
}

fn speak(acc: #(Int, Map(Int, Spoken)), step: Int) -> #(Int, Map(Int, Spoken)) {
  let #(last_inserted, when_inserted) = acc
  let assert Ok(when) = map.get(when_inserted, last_inserted)

  let to_update = case when {
    Once(_) -> 0
    Multiple(last: last, second_last: second_last) -> last - second_last
    _ -> panic
  }

  let updater = fn(res) {
    case option.unwrap(res, Never) {
      Never -> Once(first: step)
      Once(first: first) -> Multiple(last: step, second_last: first)
      Multiple(last: last, second_last: _) ->
        Multiple(last: step, second_last: last)
    }
  }

  #(to_update, map.update(when_inserted, to_update, updater))
}
