import argv
import file_streams/file_open_mode
import file_streams/file_stream
import gleam/int.{to_string}
import gleam/io
import gleam/list
import gleam/string
import sqlite/cell
import sqlite/db_header
import sqlite/page_header
import sqlite/value

pub fn main() {
  let args = argv.load().arguments

  // Uncomment this to pass the first stage
  case args {
    [database_file_path, ".dbinfo", ..] -> {
      let assert Ok(fs) =
        file_stream.open(database_file_path, [file_open_mode.Read])

      let db_header = db_header.read(fs)
      let schema_page_header = page_header.read(fs)

      io.print("database page size: ")
      io.println(to_string(db_header.page_size))

      io.print("number of tables: ")
      io.println(to_string(schema_page_header.cells))
    }
    [database_file_path, ".tables", ..] -> {
      let assert Ok(fs) =
        file_stream.open(database_file_path, [file_open_mode.Read])

      let _db_header = db_header.read(fs)
      let schema_page_header = page_header.read(fs)

      schema_page_header.pointers
      |> list.map(fn(pos) {
        let cell = cell.read_at(pos, fs)
        let assert [_, value.Text(name), ..] = cell.record
        name
      })
      |> string.join(" ")
      |> io.println
    }
    _ -> {
      io.println("Unknown command")
    }
  }
}
