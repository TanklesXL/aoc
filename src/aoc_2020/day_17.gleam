import gleam/string
import gleam/list
import gleam/iterator.{type Iterator}
import gleam/set
import gleam/dict.{type Dict as Map} as map
import gleam/option

pub fn parse(input: String) -> Space {
  use acc, row, i <- list.index_fold(string.split(input, "\n"), map.new())
  use acc, space, j <- list.index_fold(string.to_graphemes(row), acc)
  map.insert(acc, Pos(row: i, col: j, depth: 0, time: 0), case space {
    "." -> Inactive
    "#" -> Active
    _ -> panic
  })
}

const num_steps = 6

pub fn pt_1(input: Space) -> Int {
  execute(input, 3)
}

pub fn pt_2(input: Space) -> Int {
  execute(input, 4)
}

fn execute(space: Space, dimensions: Int) -> Int {
  fn() { Nil }
  |> iterator.repeatedly()
  |> iterator.take(num_steps)
  |> iterator.fold(space, fn(space, _) {
    new_world(space, neighbour_generator(dimensions))
  })
  |> map.filter(fn(_pos, cube) { cube == Active })
  |> map.size()
}

pub type Cube {
  Active
  Inactive
}

pub type Pos {
  Pos(row: Int, col: Int, depth: Int, time: Int)
}

pub type Space =
  Map(Pos, Cube)

fn neighbour_generator(with_dim dimensions: Int) -> fn(Pos) -> Iterator(Pos) {
  case dimensions {
    3 -> neighbours_3d
    4 -> neighbours_4d
    _ -> panic
  }
}

fn neighbours_3d(p: Pos) -> Iterator(Pos) {
  let offsets = [-1, 0, 1]
  {
    use acc, i <- list.fold(offsets, set.new())
    use acc, j <- list.fold(offsets, acc)
    use acc, k <- list.fold(offsets, acc)
    set.insert(
      acc,
      Pos(row: p.row + i, col: p.col + j, depth: p.depth + k, time: 0),
    )
  }
  |> set.delete(p)
  |> set.to_list()
  |> iterator.from_list()
}

fn neighbours_4d(p: Pos) -> Iterator(Pos) {
  let offsets = [-1, 0, 1]
  {
    use acc, i <- list.fold(offsets, set.new())
    use acc, j <- list.fold(offsets, acc)
    use acc, k <- list.fold(offsets, acc)
    use acc, l <- list.fold(offsets, acc)
    set.insert(
      acc,
      Pos(row: p.row + i, col: p.col + j, depth: p.depth + k, time: p.time + l),
    )
  }
  |> set.delete(p)
  |> set.to_list()
  |> iterator.from_list()
}

fn new_cube_value(
  with cube: Cube,
  at pos: Pos,
  in space: Space,
  neighbour_generator neighbours: fn(Pos) -> Iterator(Pos),
) -> Cube {
  case cube {
    Active -> handle_active(at: pos, in: space, neighbour_generator: neighbours)
    Inactive ->
      handle_inactive(at: pos, in: space, neighbour_generator: neighbours)
  }
}

fn handle_active(
  at pos: Pos,
  in space: Space,
  neighbour_generator neighbours: fn(Pos) -> Iterator(Pos),
) -> Cube {
  case
    active_neighbours_count(
      next_to: pos,
      in: space,
      neighbour_generator: neighbours,
    )
  {
    2 | 3 -> Active
    _ -> Inactive
  }
}

fn handle_inactive(
  at pos: Pos,
  in space: Space,
  neighbour_generator neighbours: fn(Pos) -> Iterator(Pos),
) -> Cube {
  case
    active_neighbours_count(
      next_to: pos,
      in: space,
      neighbour_generator: neighbours,
    )
  {
    3 -> Active
    _ -> Inactive
  }
}

fn active_neighbours_count(
  next_to pos: Pos,
  in space: Space,
  neighbour_generator neighbours: fn(Pos) -> Iterator(Pos),
) -> Int {
  pos
  |> neighbours()
  |> iterator.to_list()
  |> list.filter_map(map.get(space, _))
  |> list.filter(fn(cube) { cube == Active })
  |> list.length()
}

fn expand_world(space: Space, neighbours: fn(Pos) -> Iterator(Pos)) -> Space {
  space
  |> map.keys()
  |> iterator.from_list()
  |> iterator.flat_map(neighbours)
  |> iterator.to_list()
  |> set.from_list()
  |> set.fold(space, fn(acc, pos) {
    map.update(acc, pos, option.unwrap(_, Inactive))
  })
}

fn new_world(
  space: Space,
  neighbour_generator neighbours: fn(Pos) -> Iterator(Pos),
) -> Space {
  let expanded = expand_world(space, neighbours)
  map.from_list({
    use acc, pos, cube <- map.fold(expanded, [])
    [
      #(
        pos,
        new_cube_value(
          with: cube,
          at: pos,
          in: expanded,
          neighbour_generator: neighbours,
        ),
      ),
      ..acc
    ]
  })
}
