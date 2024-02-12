import gleam/function
import nibble
import nibble/predicates
import gleam/int
import gleam/string
import nibble/lexer

pub fn pt_1(input: String) {
  todo
}

pub fn pt_2(input: String) {
  todo
}

type Game {
  Game(id: Int, red: Int, green: Int, blue: Int)
}

type Play {
  Play(red: Int, green: Int, blue: Int)
}

type Colour {
  Red(Int)
  Green(Int)
  Blue(Int)
}

type Token {
  GameT
  NumT(Int)
  ColonT
  SemiColonT
  CommaT
  RedT
  BlueT
  GreenT
}

fn game_parser() {
  todo
}

fn plays_parser() {
  todo
}

fn play_parser() {
  use play <- nibble.do(nibble.token(todo))
  use colour <- nibble.do(nibble.one_of([nibble.token(RedT))]))
}

fn lexer() -> lexer.Lexer(Token, _) {
  lexer.simple([
    lexer.token("Game", GameT),
    lexer.int(NumT),
    lexer.token("red", RedT),
    lexer.token("red", BlueT),
    lexer.token("red", GreenT),
    lexer.token(":", ColonT),
    lexer.token(";", SemiColonT),
    lexer.token(",", CommaT),
    lexer.ignore(lexer.whitespace(Nil)),
  ])
}
