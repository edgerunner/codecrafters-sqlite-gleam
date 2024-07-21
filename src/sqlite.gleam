import argv
import file_streams/file_open_mode
import file_streams/file_stream
import gleam/int.{to_string}
import gleam/io

pub fn main() {
  // You can use print statements as follows for debugging, they'll be visible when running tests.
  io.println("Logs from your program will appear here!")

  let args = argv.load().arguments

  // Uncomment this to pass the first stage
  case args {
    [database_file_path, ".dbinfo", ..] -> {
      let assert Ok(rs) =
        file_stream.open(database_file_path, [file_open_mode.Read])
      // Skip the first 16 bytes
      let assert Ok(_bytes) = file_stream.read_bytes_exact(rs, 16)
      // The next 2 bytes hold the page size in big-endian format
      let assert Ok(page_size) = file_stream.read_uint16_be(rs)

      io.print("database page size: ")
      io.println(to_string(page_size))
    }
    _ -> {
      io.println("Unknown command")
    }
  }
}
