import argv
import file_streams/file_open_mode
import file_streams/file_stream
import gleam/int.{to_string}
import gleam/io
import sqlite/header
import sqlite/page_header

pub fn main() {
  let args = argv.load().arguments

  // Uncomment this to pass the first stage
  case args {
    [database_file_path, ".dbinfo", ..] -> {
      let assert Ok(fs) =
        file_stream.open(database_file_path, [file_open_mode.Read])

      let header = header.read(fs)
      let schema_page_header = page_header.read(fs)

      io.print("database page size: ")
      io.println(to_string(header.page_size))

      io.print("number of tables: ")
      io.println(to_string(schema_page_header.cells))
    }
    _ -> {
      io.println("Unknown command")
    }
  }
}
