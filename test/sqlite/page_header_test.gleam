import birdie
import file_streams/file_stream
import pprint
import sample
import sqlite/page_header

pub fn first_page_header_test() {
  use fs <- sample.stream()

  let assert Ok(100) =
    file_stream.position(fs, file_stream.BeginningOfFile(100))
  page_header.read(fs)
  |> pprint.format
  |> birdie.snap("First page header")
}

pub fn second_page_header_test() {
  use fs <- sample.stream()

  let assert Ok(0x1000) =
    file_stream.position(fs, file_stream.BeginningOfFile(0x1000))
  page_header.read(fs)
  |> pprint.format
  |> birdie.snap("Second page header")
}
