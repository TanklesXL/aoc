import gleam/int
import gleam/iterator.{type Iterator}
import gleam/string

type Move {
  Up(Int)
  Down(Int)
  Forward(Int)
}

fn process_input(s: String) -> Iterator(Move) {
  s
  |> string.split("\n")
  |> iterator.from_list()
  |> iterator.map(fn(line: String) -> Move {
    let assert [direction, steps] = string.split(line, " ")
    let assert Ok(steps) = int.parse(steps)

    case direction {
      "up" -> Up(steps)
      "down" -> Down(steps)
      "forward" -> Forward(steps)
      _ -> panic
    }
  })
}

type Position {
  Position(depth: Int, horizontal: Int, aim: Int)
}

pub fn pt_1(input: String) -> Int {
  let end = {
    use pos, move <- iterator.fold(
      process_input(input),
      Position(depth: 0, horizontal: 0, aim: 0),
    )
    case move {
      Up(steps) -> Position(..pos, depth: pos.depth - steps)
      Down(steps) -> Position(..pos, depth: pos.depth + steps)
      Forward(steps) -> Position(..pos, horizontal: pos.horizontal + steps)
    }
  }

  end.depth * end.horizontal
}

pub fn pt_2(input: String) -> Int {
  let end = {
    use pos, move <- iterator.fold(
      process_input(input),
      Position(depth: 0, horizontal: 0, aim: 0),
    )
    case move {
      Up(steps) -> Position(..pos, aim: pos.aim - steps)
      Down(steps) -> Position(..pos, aim: pos.aim + steps)
      Forward(steps) ->
        Position(
          ..pos,
          horizontal: pos.horizontal + steps,
          depth: pos.depth + pos.aim * steps,
        )
    }
  }
  end.depth * end.horizontal
}
