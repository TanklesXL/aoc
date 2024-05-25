import gleam/dict.{type Dict as Map} as map
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/pair
import gleam/string

pub fn parse(input: String) -> Map(Int, Op) {
  input
  |> string.split("\n")
  |> list.index_fold(map.new(), fn(acc, line, i) {
    map.insert(acc, i, to_op(line))
  })
}

pub fn pt_1(input: Map(Int, Op)) -> Int {
  input
  |> execute(0, 0)
  |> pair.first()
}

pub fn pt_2(input: Map(Int, Op)) -> Int {
  let assert Ok(#(acc, _)) =
    input
    |> permutations_with_swaps()
    |> list.find_map(fn(ops) {
      let res = execute(ops, 0, 0)
      case
        res
        |> pair.second()
        == map.size(ops)
      {
        True -> Ok(res)
        False -> Error(Nil)
      }
    })

  acc
}

pub type Op {
  NOP(by: Int)
  ACC(by: Int)
  JMP(by: Int)
}

fn permutations_with_swaps(ops: Map(Int, Op)) -> List(Map(Int, Op)) {
  ops
  |> map.filter(filter_only_jmp_and_nop)
  |> map.keys()
  |> list.map(map.update(ops, _, swap_jmp_and_nop))
}

fn filter_only_jmp_and_nop(_name: Int, op: Op) -> Bool {
  case op {
    NOP(_) | JMP(_) -> True
    _ -> False
  }
}

fn swap_jmp_and_nop(op: Option(Op)) -> Op {
  case op {
    option.Some(NOP(i)) -> JMP(i)
    option.Some(JMP(i)) -> NOP(i)
    _ -> panic
  }
}

fn to_op(line: String) -> Op {
  case string.split(line, " ") {
    ["nop", i] -> NOP(by: parse_signed_int(i))
    ["acc", i] -> ACC(by: parse_signed_int(i))
    ["jmp", i] -> JMP(by: parse_signed_int(i))
    _ -> panic
  }
}

fn parse_signed_int(s: String) -> Int {
  let assert Ok(#(sign, num)) = string.pop_grapheme(s)
  let assert Ok(i) = int.parse(num)

  case sign {
    "+" -> i
    "-" -> int.negate(i)
    _ -> panic
  }
}

fn execute(ops: Map(Int, Op), to_exec: Int, acc: Int) -> #(Int, Int) {
  case map.get(ops, to_exec) {
    Error(_) -> #(acc, to_exec)
    Ok(op) ->
      case op {
        NOP(_) -> execute(map.delete(ops, to_exec), to_exec + 1, acc)
        ACC(i) -> execute(map.delete(ops, to_exec), to_exec + 1, acc + i)
        JMP(i) -> execute(map.delete(ops, to_exec), to_exec + i, acc)
      }
  }
}
