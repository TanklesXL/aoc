import gleam/dict.{type Dict as Map} as map
import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(Masking) {
  let assert [_, ..data] = string.split(input, "mask = ")
  list.map(data, new_masking)
}

pub fn pt_1(input: List(Masking)) -> Int {
  input
  |> list.fold(map.new(), apply_value_mask)
  |> map.values()
  |> int.sum()
}

pub fn pt_2(input: List(Masking)) -> Int {
  input
  |> list.fold(map.new(), apply_address_mask)
  |> map.values()
  |> int.sum()
}

pub type Address {
  Address(location: Int, value: Int)
}

pub type Masking {
  Masking(mask: String, addresses: List(Address))
}

fn new_masking(input: String) -> Masking {
  let assert [mask, ..t] = string.split(input, "\n")

  Masking(
    mask: mask,
    addresses: t
      |> list.filter(fn(s) { s != "" })
      |> list.map(new_address),
  )
}

fn new_address(input: String) -> Address {
  let assert Ok(#(l, r)) = string.split_once(input, " = ")
  let assert Ok(value) = int.parse(r)
  let assert Ok(location) =
    l
    |> string.replace("mem[", "")
    |> string.replace("]", "")
    |> int.parse()

  Address(location: location, value: value)
}

fn apply_value_mask(acc: Map(Int, Int), masking: Masking) -> Map(Int, Int) {
  use acc, address <- list.fold(masking.addresses, acc)
  map.insert(
    acc,
    address.location,
    address.value
      |> int.bitwise_or(x_as_0(masking.mask))
      |> int.bitwise_and(x_as_1(masking.mask)),
  )
}

fn x_as_0(masking: String) -> Int {
  masking
  |> string.replace("X", "0")
  |> parse_bin()
}

fn x_as_1(masking: String) -> Int {
  masking
  |> string.replace("X", "1")
  |> parse_bin()
}

fn parse_bin(s: String) -> Int {
  s
  |> string.to_graphemes()
  |> list.index_fold(0, fn(acc, v, i) {
    let assert Ok(v) = int.parse(v)
    acc + int.bitwise_shift_left(v, 35 - i)
  })
}

fn apply_address_mask(acc: Map(Int, Int), masking: Masking) -> Map(Int, Int) {
  masking
  |> address_variants()
  |> list.fold(acc, fn(acc: Map(Int, Int), address: Address) {
    map.insert(acc, address.location, address.value)
  })
}

fn address_variants(masking: Masking) -> List(Address) {
  list.map(masking.addresses, single_address_variant(masking.mask, _))
  |> list.flatten()
}

fn single_address_variant(mask: String, address: Address) -> List(Address) {
  mask
  |> string.to_graphemes()
  |> list.zip(
    address.location
    |> to_bin()
    |> string.to_graphemes(),
  )
  |> list.map(fn(p) {
    let #(from_mask, from_addr) = p
    case from_mask {
      "0" -> from_addr
      _ -> from_mask
    }
  })
  |> variants_from_graphemes([""])
  |> list.map(fn(addr: String) {
    Address(location: parse_bin(addr), value: address.value)
  })
}

fn to_bin(num: Int) -> String {
  binarize(num, [])
}

fn binarize(num: Int, acc: List(Int)) -> String {
  case num / 2 == 0 {
    True ->
      [num % 2, ..acc]
      |> list.map(int.to_string)
      |> string.join("")
      |> string.pad_start(to: 36, with: "0")
    False -> binarize(num / 2, [num % 2, ..acc])
  }
}

fn variants_from_graphemes(l: List(String), acc: List(String)) -> List(String) {
  case l {
    [] -> acc
    [h, ..t] ->
      case h {
        "X" ->
          variants_from_graphemes(
            t,
            list.map(acc, fn(s) {
              [string.append(s, "1"), string.append(s, "0")]
            })
              |> list.flatten(),
          )
        b -> variants_from_graphemes(t, list.map(acc, string.append(_, b)))
      }
  }
}
