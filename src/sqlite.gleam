import argv
import file_streams/file_open_mode
import file_streams/file_stream
import gleam/int.{to_string}
import gleam/io
import sqlite/header

pub fn main() {
  // You can use print statements as follows for debugging, they'll be visible when running tests.
  io.println("Logs from your program will appear here!")

  let args = argv.load().arguments

  // Uncomment this to pass the first stage
  case args {
    [database_file_path, ".dbinfo", ..] -> {
      let assert Ok(fs) =
        file_stream.open(database_file_path, [file_open_mode.Read])

      let header = header.read(fs)

      io.print("database page size: ")
      io.println(to_string(header.page_size))
    }
    _ -> {
      io.println("Unknown command")
    }
  }
}
