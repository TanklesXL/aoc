import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

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
  input: List(dict.Dict(Int, a)),
  index: Int,
  finding: fn(List(a)) -> a,
) -> Result(List(a), Nil) {
  case input {
    [] -> Error(Nil)

    [res] ->
      Ok(
        res
        |> dict.to_list
        |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
        |> list.map(pair.second),
      )

    _ -> {
      use to_find <- result.try(list.try_map(input, dict.get(_, index)))

      input
      |> list.filter(fn(line) { dict.get(line, index) == Ok(finding(to_find)) })
      |> sieve(index + 1, finding)
    }
  }
}

pub fn pt_2(input: List(List(Int))) -> Int {
  let input = {
    use x <- list.map(input)
    use acc, elem, idx <- list.index_fold(x, dict.new())
    dict.insert(acc, idx, elem)
  }

  let assert Ok(oxygen) = sieve(input, 0, most_common_bit)
  let assert Ok(oxygen) = int.undigits(oxygen, 2)

  let assert Ok(co2) = sieve(input, 0, least_common_bit)
  let assert Ok(co2) = int.undigits(co2, 2)

  oxygen * co2
}
