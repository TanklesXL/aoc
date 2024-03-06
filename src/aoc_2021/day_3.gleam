import gleam/string
import gleam/list
import gleam/int

type Array(a)

@external(erlang, "array", "from_list")
fn from_list(l: List(a)) -> Array(a)

@external(erlang, "array", "to_list")
fn to_list(a: Array(a)) -> List(a)

@external(erlang, "array", "get")
fn get(i: Int, a: Array(a)) -> a

pub fn parse(input: String) -> List(List(Int)) {
  let assert Ok(input) =
    input
    |> string.split("\n")
    |> list.map(string.to_graphemes)
    |> list.try_map(list.try_map(_, int.parse))

  input
}

pub fn pt_1(input: List(List(Int))) -> Int {
  let gamma_list =
    input
    |> list.transpose()
    |> list.map(most_common_bit)

  let assert Ok(gamma) = int.undigits(gamma_list, 2)

  let assert Ok(epsilon) =
    gamma_list
    |> list.map(fn(i) { 1 - i })
    |> int.undigits(2)

  gamma * epsilon
}

fn most_common_bit(l: List(Int)) -> Int {
  list.fold(l, 1, fn(acc, elem) {
    acc
    + case elem {
      1 -> 1
      0 -> -1
      _ -> panic
    }
  })
  |> int.clamp(min: 0, max: 1)
}

fn least_common_bit(l: List(Int)) -> Int {
  1 - most_common_bit(l)
}

fn sieve(
  input: List(Array(a)),
  index: Int,
  finding: fn(List(a)) -> a,
) -> Result(List(a), Nil) {
  case input {
    [] -> Error(Nil)

    [res] -> Ok(to_list(res))

    _ -> {
      let to_find =
        input
        |> list.map(get(index, _))
        |> finding()
      input
      |> list.filter(fn(line) { get(index, line) == to_find })
      |> sieve(index + 1, finding)
    }
  }
}

pub fn pt_2(input: List(List(Int))) -> Int {
  let input = list.map(input, from_list)

  let assert Ok(oxygen) = sieve(input, 0, most_common_bit)
  let assert Ok(oxygen) = int.undigits(oxygen, 2)

  let assert Ok(co2) = sieve(input, 0, least_common_bit)
  let assert Ok(co2) = int.undigits(co2, 2)

  oxygen * co2
}
