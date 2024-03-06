import gleam/list
import gleam/dict.{type Dict as Map} as map
import gleam/result
import gleam/string
import gleam/int

pub fn parse(input: String) -> Map(Int, Map(Int, String)) {
  input
  |> string.split(on: "\n")
  |> list.index_map(fn(row, i) { #(i, string.to_graphemes(row)) })
  |> map.from_list()
  |> map.map_values(fn(_, row) {
    list.range(0, list.length(row))
    |> list.zip(row)
    |> map.from_list()
  })
}

const pt_1_slope = Slope(right: 3, down: 1)

pub fn pt_1(input: Map(Int, Map(Int, String))) -> Int {
  count_trees(
    in: input,
    from: Pos(row_i: 0, column_i: 0),
    along: pt_1_slope,
    with_acc: 0,
  )
}

const pt_2_slopes = [
  Slope(right: 1, down: 1),
  Slope(right: 3, down: 1),
  Slope(right: 5, down: 1),
  Slope(right: 7, down: 1),
  Slope(right: 1, down: 2),
]

pub fn pt_2(input: Map(Int, Map(Int, String))) -> Int {
  count_trees(
    in: input,
    from: Pos(row_i: 0, column_i: 0),
    along: _,
    with_acc: 0,
  )
  |> list.map(pt_2_slopes, _)
  |> int.product()
}

type Slope {
  Slope(down: Int, right: Int)
}

type Pos {
  Pos(row_i: Int, column_i: Int)
}

fn count_trees(
  in input: Map(Int, Map(Int, String)),
  from current: Pos,
  along slope: Slope,
  with_acc found: Int,
) -> Int {
  case
    input
    |> map.get(current.row_i)
    |> result.then(fn(row) { map.get(row, current.column_i % map.size(row)) })
  {
    Ok(space) -> {
      let found = case space {
        "." -> found
        "#" -> found + 1
        _ -> panic
      }
      let next =
        Pos(
          row_i: current.row_i + slope.down,
          column_i: current.column_i + slope.right,
        )
      count_trees(in: input, from: next, along: slope, with_acc: found)
    }
    _ -> found
  }
}
