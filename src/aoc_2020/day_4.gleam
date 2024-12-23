import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub fn parse(input: String) -> List(List(#(String, String))) {
  input
  |> string.split("\n\n")
  |> list.map(with: process_passport)
}

const mandatory_keys = ["ecl", "pid", "eyr", "hcl", "byr", "iyr", "hgt"]

pub fn pt_1(input: List(List(#(String, String)))) -> Int {
  input
  |> list.filter(has_keys(_, mandatory_keys))
  |> list.length()
}

pub fn pt_2(input: List(List(#(String, String)))) -> Int {
  input
  |> list.filter(is_valid_passport)
  |> list.length()
}

fn process_passport(passport: String) -> List(#(String, String)) {
  passport
  |> string.split("\n")
  |> list.map(string.split(_, " "))
  |> list.flatten()
  |> list.map(fn(pair) {
    let assert [key, val] = string.split(pair, ":")
    #(key, val)
  })
}

fn has_keys(passport: List(#(String, String)), keys: List(String)) -> Bool {
  list.all(keys, fn(x) {
    list.key_find(passport, x)
    |> result.is_ok
  })
}

fn validate_as_int(s: String, min: Int, max: Int) -> Bool {
  case int.parse(s) {
    Ok(i) -> i >= min && i <= max
    _ -> False
  }
}

fn is_valid_passport(passport: List(#(String, String))) -> Bool {
  [
    #("byr", validate_as_int(_, 1920, 2002)),
    #("iyr", validate_as_int(_, 2010, 2020)),
    #("eyr", validate_as_int(_, 2020, 2030)),
    #("hgt", fn(hgt) {
      case string.slice(hgt, -2, 2) {
        "cm" ->
          hgt
          |> string.drop_end(2)
          |> validate_as_int(150, 193)
        "in" ->
          hgt
          |> string.drop_end(2)
          |> validate_as_int(59, 76)
        _ -> False
      }
    }),
    #("hcl", fn(hcl) {
      case string.to_graphemes(hcl) {
        ["#", ..body] -> {
          let acceptable = [
            "a", "b", "c", "d", "e", "f", "0", "1", "2", "3", "4", "5", "6", "7",
            "8", "9",
          ]
          list.length(body) == 6 && list.all(body, list.contains(acceptable, _))
        }
        _ -> False
      }
    }),
    #("ecl", list.contains(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"], _)),
    #("pid", fn(pid) { string.length(pid) == 9 && result.is_ok(int.parse(pid)) }),
  ]
  |> list.all(fn(validator: #(String, fn(String) -> Bool)) {
    case list.key_find(passport, validator.0) {
      Ok(val) -> validator.1(val)
      _ -> False
    }
  })
}
