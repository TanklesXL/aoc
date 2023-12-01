import aoc_2023/day_1
import gleeunit/should

pub fn pt_1_test() {
  "1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet"
  |> day_1.pt_1
  |> should.equal(142)
}

pub fn pt_2_test() {
  "two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen"
  |> day_1.pt_2
  |> should.equal(281)
}
