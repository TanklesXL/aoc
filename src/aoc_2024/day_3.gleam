import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import nibble.{do, return}
import nibble/lexer

pub type T {
  M
  U
  L
  Open
  Close
  Comma
  Number(Int)
  Other
}

pub fn pt_1(input: String) {
  let assert Ok(out) =
    [
      lexer.token("m", M),
      lexer.token("u", U),
      lexer.token("l", L),
      lexer.token("(", Open),
      lexer.token(")", Close),
      lexer.token(",", Comma),
      lexer.int(Number),
      lexer.keep(fn(the_string, _) {
        case
          the_string
          |> string.to_graphemes
          |> list.map(fn(char) { string.contains("mul(),0123456789", char) })
          |> list.all(fn(x) { x })
        {
          True -> Error(Nil)
          False -> Ok(Other)
        }
      }),
    ]
    |> lexer.simple()
    |> lexer.run(input, _)

  let int_parser = {
    // Use `take_map` to only consume certain kinds of tokens and transform the
    // result.
    use tok <- nibble.take_map("expected number")
    case tok {
      Number(n) -> option.Some(n)
      _ -> option.None
    }
  }

  let parser = {
    use acc <- nibble.loop(0)
    nibble.one_of([
      {
        use _ <- do(nibble.token(M))
        use _ <- do(nibble.token(U))
        use _ <- do(nibble.token(L))
        use _ <- do(nibble.token(Open))
        use x <- do(int_parser)
        use _ <- do(nibble.token(Comma))
        use y <- do(int_parser)
        use _ <- do(nibble.token(Close))

        { x * y }
        |> return
      }
        |> nibble.backtrackable
        |> nibble.map(int.add(acc, _))
        |> nibble.map(nibble.Continue),
      // if that fails take everything until we find another `m`
      nibble.take_until1("wtf bro", fn(tok) { tok == M })
        |> nibble.replace(acc)
        |> nibble.map(nibble.Continue),
      // we need to explicitly handle the case where we have an `m`
      // but `mul_parser` failed
      nibble.token(M)
        |> nibble.replace(acc)
        |> nibble.map(nibble.Continue),
      // we reached the end, return our list
      nibble.eof()
        |> nibble.map(fn(_) { acc })
        |> nibble.map(nibble.Break),
    ])
  }

  let assert Ok(out) = nibble.run(out, parser)

  out
}

pub fn pt_2(input: String) {
  input
  |> string.split("do()")
  |> list.fold("", fn(acc, s) {
    acc
    <> string.split(s, "don't()")
    |> list.first
    |> result.unwrap("")
  })
  |> pt_1
}
