import gleam/int
import gleam/list
import gleam/string
import gleam/result

pub fn pt_1(input: String) -> Int {
  let assert [start_time, buses] = string.split(input, "\n")
  let assert Ok(start_time) = int.parse(start_time)

  let buses =
    buses
    |> string.split(",")
    |> list.filter(fn(s) { s != "x" })
    |> list.map(fn(s) {
      let assert Ok(id) = int.parse(s)
      id
    })

  let assert Ok(next) =
    buses
    |> list.map(next_departure_time(_, start_time))
    |> list.sort(fn(a: Departure, b: Departure) {
      int.compare(a.wait_time, b.wait_time)
    })
    |> list.first()

  next.id * next.wait_time
}

type Departure {
  Departure(id: Int, wait_time: Int)
}

fn next_departure_time(bus_id: Int, start_time: Int) -> Departure {
  Departure(id: bus_id, wait_time: bus_id - { start_time + bus_id } % bus_id)
}

pub fn pt_2(input: String) -> Int {
  let assert [_, buses] = string.split(input, "\n")

  buses
  |> string.split(",")
  |> list.index_map(fn(i, s) { #(i, s) })
  |> list.filter_map(fn(p) {
    let #(offset, id) = p
    use id <- result.try(int.parse(id))
    let offset = case id > offset {
      True -> id - offset
      False -> id - offset % id
    }
    Ok(Bus(id: id, offset: offset))
  })
  |> find_min()
}

fn invmod(a: Int, m: Int) -> Int {
  case m {
    1 -> 0
    _ ->
      case inner_ext_euclid(a, m, 0, 1) {
        x if x < 0 -> x + m
        x -> x
      }
  }
}

fn inner_ext_euclid(a, m, x0, x1) -> Int {
  case a > 1 {
    True -> inner_ext_euclid(m, a % m, x1 - a / m * x0, x0)
    False -> x1
  }
}

type Bus {
  Bus(id: Int, offset: Int)
}

fn find_min(buses: List(Bus)) -> Int {
  let prod = list.fold(buses, 1, fn(acc, bus: Bus) { bus.id * acc })
  list.fold(buses, 0, fn(acc: Int, bus: Bus) {
    let pp = prod / bus.id
    acc + bus.offset * invmod(pp, bus.id) * pp
  }) % prod
}
