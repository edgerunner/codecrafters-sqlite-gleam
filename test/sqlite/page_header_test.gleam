import birdie
import file_streams/file_open_mode
import file_streams/file_stream
import pprint
import sqlite/page_header

pub fn first_page_header_test() {
  use fs <- with_sample()

  let assert Ok(100) =
    file_stream.position(fs, file_stream.BeginningOfFile(100))
  page_header.read(fs)
  |> pprint.format
  |> birdie.snap("First page header")
}

pub fn second_page_header_test() {
  use fs <- with_sample()

  let assert Ok(0x1000) =
    file_stream.position(fs, file_stream.BeginningOfFile(0x1000))
  page_header.read(fs)
  |> pprint.format
  |> birdie.snap("Second page header")
}

const database_file_path = "sample.db"

fn with_sample(test_body: fn(file_stream.FileStream) -> Nil) {
  let assert Ok(fs) =
    file_stream.open(database_file_path, [file_open_mode.Read])
  test_body(fs)
  let assert Ok(_) = file_stream.close(fs)
}
