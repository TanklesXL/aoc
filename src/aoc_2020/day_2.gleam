import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> List(String) {
  string.split(input, "\n")
}

pub fn pt_1(input: List(String)) -> Int {
  input
  |> list.filter(satisfactory(_, is_valid_sled_policy))
  |> list.length()
}

pub fn pt_2(input: List(String)) -> Int {
  input
  |> list.filter(satisfactory(_, is_valid_toboggan_policy))
  |> list.length()
}

type Policy {
  Policy(left: Int, right: Int, letter: String, code: String)
}

fn to_policy(policy: String) -> Result(Policy, Nil) {
  let assert [range, letter, code] = string.split(policy, " ")
  let letter = string.drop_right(letter, 1)
  use #(left, right) <- result.try(string.split_once(range, "-"))
  use left <- result.try(int.parse(left))
  use right <- result.try(int.parse(right))
  Ok(Policy(left, right, letter, code))
}

fn satisfactory(s: String, validator: fn(Policy) -> Bool) -> Bool {
  s
  |> to_policy()
  |> result.map(validator)
  |> result.unwrap(False)
}

fn is_valid_sled_policy(policy: Policy) -> Bool {
  policy.code
  |> string.to_graphemes()
  |> list.filter(fn(letter) { letter == policy.letter })
  |> list.length()
  |> fn(count) { count >= policy.left && count <= policy.right }
}

fn is_valid_toboggan_policy(policy: Policy) -> Bool {
  let extract_left_and_right = fn(l) {
    use at_left <- result.try(
      l
      |> list.drop(policy.left - 1)
      |> list.first,
    )

    use at_right <- result.try(
      l
      |> list.drop(policy.right - 1)
      |> list.first,
    )
    Ok([at_left, at_right])
  }

  case
    policy.code
    |> string.to_graphemes()
    |> extract_left_and_right()
  {
    Ok(res) ->
      res
      |> list.filter(fn(letter) { letter == policy.letter })
      |> list.length()
      |> fn(count) { count == 1 }
    _err -> False
  }
}
