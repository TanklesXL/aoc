import gleam/list
import gleam/string
import gleam/pair
import gleam/int

fn repeatedly(with start: a, num times: Int, do f: fn(a) -> a) -> a {
  case times {
    0 -> start
    _ -> repeatedly(f(start), times - 1, f)
  }
}

/// represent problem as data
pub type RPS {
  Rock
  Paper
  Scissors
}

/// convert independent moves 
fn play_to_rps(s: String) {
  case s {
    "A" | "X" -> Rock
    "B" | "Y" -> Paper
    "C" | "Z" -> Scissors
    _ -> panic
  }
}

/// calculate the value of a single game
fn score(plays: #(RPS, RPS)) {
  case plays.0, plays.1 {
    // draw
    _, _ if plays.0 == plays.1 -> 3
    // loss
    Scissors, Paper | Rock, Scissors | Paper, Rock -> 0
    // win
    Paper, Scissors | Scissors, Rock | Rock, Paper -> 6
    _, _ -> panic
  } + // score the hand I played
  case plays.1 {
    Rock -> 1
    Paper -> 2
    Scissors -> 3
  }
}

/// parse the input and play all hands, calculate the final score 
fn solve(input, f) {
  let assert Ok(games) =
    input
    |> string.split("\n")
    |> list.try_map(string.split_once(_, on: " "))

  games
  |> list.map(fn(tup) {
    let tup = pair.map_first(tup, play_to_rps)
    score(#(tup.0, f(tup.0, tup.1)))
  })
  |> int.sum
}

/// pt_1 solves both plays independently
pub fn pt_1(input: String) {
  use _, s <- solve(input)
  play_to_rps(s)
}

// helpers for pt_2

/// given the current move, get the one that beats it
fn beats(rps) {
  case rps {
    Paper -> Scissors
    Rock -> Paper
    Scissors -> Rock
  }
}

/// figure out how many moves to shift by
fn shift(s) {
  case s {
    // lose
    "X" -> 2
    // draw
    "Y" -> 0
    // win
    "Z" -> 1
    _ -> panic
  }
}

/// pt_2 solves my play as dependent of the opponent's
pub fn pt_2(input: String) {
  use play, s <- solve(input)
  s
  |> shift
  |> repeatedly(play, _, beats)
}
