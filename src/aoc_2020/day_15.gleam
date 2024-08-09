import gleam/dict.{type Dict as Map} as map
import gleam/int
import gleam/iterator
import gleam/list
import gleam/option
import gleam/pair
import gleam/string

pub fn parse(input: String) -> #(Int, Map(Int, Spoken)) {
  let assert Ok(input) =
    input
    |> string.split(",")
    |> list.try_map(int.parse)

  let assert Ok(seed) = list.last(input)

  #(seed, init(input))
}

const steps_1 = 2020

const steps_2 = 30_000_000

pub fn pt_1(input: #(Int, map.Dict(Int, Spoken))) -> Int {
  execute(input, steps_1)
}

pub fn pt_2(input: #(Int, map.Dict(Int, Spoken))) -> Int {
  execute(input, steps_2)
}

fn execute(input: #(Int, map.Dict(Int, Spoken)), iterations: Int) -> Int {
  iterator.range(map.size(input.1) + 1, iterations)
  |> iterator.fold(input, speak)
  |> pair.first()
}

pub type Spoken {
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

  #(to_update, map.upsert(when_inserted, to_update, updater))
}
