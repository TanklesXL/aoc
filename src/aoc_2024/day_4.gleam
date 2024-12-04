import gleam/bool
import gleam/dict
import gleam/list
import gleam/string

// place on a grid
pub type Pos {
  Pos(row: Int, col: Int)
}

// movement from somewhere on a grid to somewhere else
pub type Move {
  Move(row: Int, col: Int)
}

fn do_move(pos: Pos, move: Move) -> Pos {
  Pos(row: pos.row + move.row, col: pos.col + move.col)
}

pub fn parse(input: String) -> dict.Dict(Pos, String) {
  use acc, line, row <- list.index_fold(string.split(input, "\n"), dict.new())
  use acc, letter, col <- list.index_fold(string.to_graphemes(line), acc)
  dict.insert(acc, Pos(row:, col:), letter)
}

fn verify(
  sequence: List(String),
  pos: Pos,
  data: dict.Dict(Pos, String),
  move: Move,
) -> Bool {
  case sequence {
    [] -> True
    [head, ..tail] ->
      case dict.get(data, pos) {
        Ok(letter) if letter == head ->
          verify(tail, do_move(pos, move), data, move)
        _ -> False
      }
  }
}

pub fn pt_1(input: dict.Dict(Pos, String)) {
  use acc, start, letter <- dict.fold(input, 0)
  use <- bool.guard(when: letter != "X", return: acc)
  acc
  + list.count(
    [
      Move(0, -1),
      Move(0, 1),
      Move(1, -1),
      Move(1, 0),
      Move(1, 1),
      Move(-1, -1),
      Move(-1, 0),
      Move(-1, 1),
    ],
    verify(["X", "M", "A", "S"], start, input, _),
  )
}

pub fn pt_2(input: dict.Dict(Pos, String)) {
  use acc, pos, letter <- dict.fold(input, 0)
  use <- bool.guard(when: letter != "A", return: acc)
  acc
  + {
    use moves <- list.count([
      // M  S
      //  A
      // M  S
      #(Move(row: 1, col: 1), Move(row: -1, col: 1)),
      // M  M
      //  A
      // S  S
      #(Move(row: 1, col: 1), Move(row: 1, col: -1)),
      // S  M
      //  A
      // S  M
      #(Move(row: 1, col: -1), Move(row: -1, col: -1)),
      // S  S
      //  A
      // M  M
      #(Move(row: -1, col: 1), Move(row: -1, col: -1)),
    ])

    let verify = fn(move: Move) {
      Move(row: -move.row, col: -move.col)
      |> do_move(pos, _)
      |> verify(["M", "A", "S"], _, input, move)
    }

    verify(moves.0) && verify(moves.1)
  }
}
