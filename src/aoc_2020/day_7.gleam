import gleam/bool
import gleam/dict.{type Dict as Map} as map
import gleam/int
import gleam/iterator
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn parse(input: String) -> Bags {
  input
  |> string.split("\n")
  |> iterator.from_list()
  |> iterator.map(string.replace(_, ".", ""))
  |> iterator.map(string.replace(_, " bags", ""))
  |> iterator.map(string.replace(_, " bag", ""))
  |> iterator.map(string.split(_, " contain "))
  |> iterator.map(fn(line) {
    let assert [outer, inner] = line
    #(outer, parse_capacity(inner))
  })
  |> iterator.to_list()
  |> map.from_list()
}

const goal_bag = "shiny gold"

pub fn pt_1(input: Bags) -> Int {
  how_many_can_hold_goal(input, goal_bag)
}

pub fn pt_2(input: Bags) -> Int {
  let assert Ok(contents_of_goal_bag) = map.get(input, goal_bag)
  sum_with_inside(input, contents_of_goal_bag)
}

pub type Capacity {
  Capacity(name: String, amount: Int)
}

pub type Bags =
  Map(String, List(Capacity))

fn parse_capacity(capacities: String) -> List(Capacity) {
  case capacities {
    "no other" -> []
    _ ->
      capacities
      |> string.split(", ")
      |> list.map(fn(capacity) {
        let assert Ok(#(count, name)) = string.split_once(capacity, " ")
        let assert Ok(count) = int.parse(count)
        Capacity(name: name, amount: count)
      })
  }
}

fn how_many_can_hold_goal(in bags: Bags, with_goal bag: String) -> Int {
  let starting_set = set.insert(set.new(), bag)

  bags
  |> can_hold(starting_set)
  |> set.delete(goal_bag)
  |> set.size()
}

fn can_hold(in bags: Bags, already_seen seen: Set(String)) -> Set(String) {
  let new =
    bags
    |> map.filter(fn(name, capacities) {
      bool.negate(set.contains(seen, name))
      && list.any(capacities, fn(capacity: Capacity) {
        set.contains(seen, capacity.name)
      })
    })
    |> map.keys()

  case list.length(new) {
    0 -> seen
    _ -> can_hold(in: bags, already_seen: set.union(seen, set.from_list(new)))
  }
}

// this function is ineffecient as it potentially computes the same bag values multiple times
fn sum_with_inside(bags: Bags, contents: List(Capacity)) -> Int {
  use acc, capacity <- list.fold(contents, 0)
  let assert Ok(contents) = map.get(bags, capacity.name)
  acc + capacity.amount + capacity.amount * sum_with_inside(bags, contents)
}
