import gleam/list
import gleam/map.{type Map}
import gleam/int
import gleam/result
import gleam/string

pub fn pt_1(input: String) -> Int {
  let assert Ok(input) =
    input
    |> string.split("\n")
    |> list.try_map(int.parse)

  let counts =
    input
    |> setup()
    |> deltas(0, [])

  let singles =
    list.filter(counts, fn(x) { x == 1 })
    |> list.length()
  let triples =
    list.filter(counts, fn(x) { x == 3 })
    |> list.length()

  singles * triples
}

fn setup(l: List(Int)) -> List(Int) {
  let l = list.sort(l, int.compare)
  let max = last_or_zero(l)
  list.append(l, [max + 3])
}

fn last_or_zero(l: List(Int)) -> Int {
  let assert Ok(last) = list.at(l, list.length(l) - 1)
  last
}

fn deltas(l: List(Int), last: Int, acc: List(Int)) -> List(Int) {
  case l {
    [] -> acc
    [h, ..t] -> deltas(t, h, [h - last, ..acc])
  }
}

pub fn pt_2(input: String) -> Int {
  let assert Ok(input) =
    input
    |> string.split("\n")
    |> list.try_map(int.parse)
  let input = setup(input)

  let assert Ok(output) =
    input
    |> list.fold(map.from_list([#(0, 1)]), accumulate_jolts)
    |> map.get(last_or_zero(input))

  output
}

fn accumulate_jolts(options: Map(Int, Int), target_jolts: Int) -> Map(Int, Int) {
  map.insert(
    options,
    target_jolts,
    list.fold([1, 2, 3], 0, fn(acc, diff) {
      acc + {
        options
        |> map.get(target_jolts - diff)
        |> result.unwrap(0)
      }
    }),
  )
}
