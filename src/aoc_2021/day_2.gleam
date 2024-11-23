import gleam/int
import gleam/string
import gleam/yielder.{type Yielder as Iterator} as iterator

pub type Move {
  Up(Int)
  Down(Int)
  Forward(Int)
}

pub fn parse(s: String) -> Iterator(Move) {
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

pub fn pt_1(input: Iterator(Move)) -> Int {
  let end = {
    use pos, move <- iterator.fold(
      input,
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

pub fn pt_2(input: Iterator(Move)) -> Int {
  let end = {
    use pos, move <- iterator.fold(
      input,
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
