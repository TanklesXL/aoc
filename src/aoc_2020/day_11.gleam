import gleam/string
import gleam/list
import gleam/result
import gleam/map.{type Map}

pub fn pt_1(input: String) -> Int {
  input
  |> pre_process()
  |> execute(handle_empty(adjacent_seats), handle_full(adjacent_seats, 4))
  |> map.fold([], fn(acc, _, row) {
    map.fold(row, acc, fn(acc, _, spot) { [spot, ..acc] })
  })
  |> list.filter(fn(spot) { spot == FullSeat })
  |> list.length()
}

pub fn pt_2(input: String) -> Int {
  input
  |> pre_process()
  |> execute(handle_empty(visible_seats), handle_full(visible_seats, 5))
  |> map.fold([], fn(acc, _, row) {
    map.fold(row, acc, fn(acc, _, spot) { [spot, ..acc] })
  })
  |> list.filter(fn(spot) { spot == FullSeat })
  |> list.length()
}

type Spot {
  Wall
  Floor
  EmptySeat
  FullSeat
}

type Seats =
  Map(Int, Map(Int, Spot))

fn pre_process(input: String) -> Seats {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.to_graphemes()
    |> list.index_fold(map.new(), fn(acc, char, i) {
      map.insert(acc, i, case char {
        "." -> Floor
        "L" -> EmptySeat
        _ -> panic
      })
    })
  })
  |> list.index_fold(map.new(), fn(acc, row, i) { map.insert(acc, i, row) })
}

type Pos {
  Pos(row: Int, col: Int)
}

type NeighbourGenerator =
  fn(Pos, Seats) -> List(Spot)

fn adjacent(to p: Pos) -> List(Pos) {
  [
    Pos(..p, row: p.row - 1),
    Pos(..p, row: p.row + 1),
    Pos(..p, col: p.col - 1),
    Pos(..p, col: p.col + 1),
    Pos(row: p.row - 1, col: p.col - 1),
    Pos(row: p.row - 1, col: p.col + 1),
    Pos(row: p.row + 1, col: p.col - 1),
    Pos(row: p.row + 1, col: p.col + 1),
  ]
}

fn adjacent_seats(to p: Pos, in seats: Seats) -> List(Spot) {
  p
  |> adjacent()
  |> list.map(fn(q: Pos) {
    seats
    |> map.get(q.row)
    |> result.then(map.get(_, q.col))
    |> result.unwrap(Wall)
  })
}

fn visible_seats(to pos: Pos, in seats: Seats) -> List(Spot) {
  pos
  |> adjacent()
  |> list.map(go_until_seat(_, pos, seats))
}

import gleam/int
import gleam/order

fn go_until_seat(dest: Pos, origin: Pos, seats: Seats) -> Spot {
  case
    seats
    |> map.get(dest.row)
    |> result.then(map.get(_, dest.col))
    |> result.unwrap(Wall)
  {
    Floor -> {
      let next = fn(old, new) {
        case int.compare(new - old, 0) {
          order.Lt -> new - 1
          order.Eq -> new
          order.Gt -> new + 1
        }
      }
      go_until_seat(
        Pos(row: next(origin.row, dest.row), col: next(origin.col, dest.col)),
        origin,
        seats,
      )
    }
    spot -> spot
  }
}

type SwapChecker =
  fn(Pos, Seats) -> Bool

fn sum_full_seats(acc: Int, spot: Spot) -> Int {
  case spot {
    FullSeat -> acc + 1
    _ -> acc
  }
}

fn handle_empty(with_neighbours generator: NeighbourGenerator) -> SwapChecker {
  fn(p, seats) -> Bool {
    p
    |> generator(seats)
    |> list.fold(0, sum_full_seats) == 0
  }
}

fn handle_full(
  with_neighbours generator: NeighbourGenerator,
  with_threshold threshold: Int,
) -> SwapChecker {
  fn(p, seats) -> Bool {
    p
    |> generator(seats)
    |> list.fold(0, sum_full_seats) >= threshold
  }
}

fn execute(
  seats: Seats,
  handle_empty: SwapChecker,
  handle_full: SwapChecker,
) -> Seats {
  case
    seats
    |> check_all_once(handle_empty, handle_full)
  {
    [] -> seats
    to_swap ->
      to_swap
      |> list.fold(seats, do_swap)
      |> execute(handle_empty, handle_full)
  }
}

fn check_all_once(
  seats: Seats,
  handle_empty: SwapChecker,
  handle_full: SwapChecker,
) -> List(Pos) {
  map.fold(seats, [], fn(acc, r_i, row) {
    map.fold(row, acc, fn(acc, c_i, spot) {
      let pos = Pos(row: r_i, col: c_i)
      case should_swap(spot, pos, seats, handle_empty, handle_full) {
        True -> [pos, ..acc]
        False -> acc
      }
    })
  })
}

fn should_swap(
  spot: Spot,
  p: Pos,
  seats: Seats,
  handle_empty: SwapChecker,
  handle_full: SwapChecker,
) -> Bool {
  case spot {
    Floor -> False
    EmptySeat -> handle_empty(p, seats)
    FullSeat -> handle_full(p, seats)
    _ -> panic
  }
}

fn do_swap(seats: Seats, pos: Pos) -> Seats {
  let assert Ok(row) = map.get(seats, pos.row)
  let assert Ok(spot) = map.get(row, pos.col)

  map.insert(seats, pos.row, map.insert(row, pos.col, case spot {
    EmptySeat -> FullSeat
    FullSeat -> EmptySeat
    _ -> panic
  }))
}
