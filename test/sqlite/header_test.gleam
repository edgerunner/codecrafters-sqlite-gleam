import birdie
import file_streams/file_open_mode
import file_streams/file_stream
import pprint
import sqlite/header

const database_file_path = "sample.db"

pub fn header_read_test() {
  use file <- with_sample()

  header.read(file)
  |> pprint.with_config(pprint.Config(
    pprint.Unstyled,
    pprint.KeepBitArrays,
    pprint.Labels,
  ))
  |> birdie.snap("Sample header")
}

fn with_sample(test_body: fn(file_stream.FileStream) -> Nil) {
  let assert Ok(fs) =
    file_stream.open(database_file_path, [file_open_mode.Read])
  test_body(fs)
  let assert Ok(_) = file_stream.close(fs)
}
