import gleam/dict.{type Dict as Map} as map
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string

// represent filesystem data
pub type FS {
  Dir(name: String)
  File(size: Int, name: String)
}

// represent a command and any output
pub type Command {
  Cd(input: String)
  Ls(output: List(FS))
}

pub fn parse(input: String) -> List(Command) {
  input
  |> string.split("$")
  |> list.filter_map(parse_cmd)
}

fn parse_cmd(cmd: String) -> Result(Command, Nil) {
  case
    cmd
    |> string.trim
    |> string.split("\n")
  {
    ["cd " <> dir] -> Ok(Cd(dir))
    ["ls", ..outputs] ->
      {
        use output <- list.try_map(outputs)
        case output {
          "dir " <> dir -> Ok(Dir(dir))
          _ -> {
            let assert Ok(#(size, name)) = string.split_once(output, " ")
            let assert Ok(size) = int.parse(size)
            Ok(File(size: size, name: name))
          }
        }
      }
      |> result.map(Ls)
    _ -> Error(Nil)
  }
}

fn dir_sizes(l: List(#(List(String), List(FS)))) {
  // sort each path and output by path length, with length decreasing
  let sorted =
    list.sort(l, fn(e1, e2) {
      int.compare(list.length(e2.0), list.length(e1.0))
    })

  // for each new path, calculate the total size, checking the size of any subdirs
  use tree, elem <- list.fold(sorted, map.new())
  use tree, fs <- list.fold(elem.1, tree)
  use size <- map.update(tree, elem.0)
  let cum_size = option.unwrap(size, 0)
  cum_size
  + case fs {
    File(size: fs_size, ..) -> fs_size
    Dir(subdir) -> {
      // due to the above sorting subdirectories MUST already have been seen
      // and will therefore have a size already determined
      let assert Ok(subdir_size) = map.get(tree, [subdir, ..elem.0])
      subdir_size
    }
  }
}

// figure out the resulting path of a given command
fn path(from current_path: List(String), do command: Command) -> List(String) {
  case command {
    Cd("/") -> []
    Cd("..") -> {
      let assert [_, ..xs] = current_path
      xs
    }
    Cd(dir) -> [dir, ..current_path]
    Ls(_) -> current_path
  }
}

fn solve(commands: List(Command), f: fn(Map(List(String), Int)) -> Int) -> Int {
  commands
  // generate the directory paths of each command
  |> list.scan([], path)
  |> list.zip(commands)
  // we only care about the `ls` commands
  |> list.filter_map(fn(p) {
    case p.1 {
      Ls(out) -> Ok(#(p.0, out))
      _ -> Error(Nil)
    }
  })
  // generate the directory size map
  |> dir_sizes
  // run provided solution
  |> f
}

pub fn pt_1(input: List(Command)) {
  use sizes <- solve(input)
  use acc, _, size <- map.fold(over: sizes, from: 0)
  case size <= 100_000 {
    True -> acc + size
    False -> acc
  }
}

pub fn pt_2(input: List(Command)) {
  use sizes <- solve(input)
  let assert Ok(total) = map.get(sizes, [])

  let delete_at_least = total - { 70_000_000 - 30_000_000 }

  let assert [#(_, size), ..] =
    sizes
    |> map.filter(fn(_, size) { size >= delete_at_least })
    |> map.to_list
    |> list.sort(fn(d1, d2) { int.compare(d1.1, d2.1) })

  size
}
