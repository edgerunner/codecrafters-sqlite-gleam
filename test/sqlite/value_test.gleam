import birdie
import file_streams/file_stream
import pprint
import sample
import sqlite/serial_type
import sqlite/value

pub fn first_value_of_first_record_test() {
  use fs <- sample.stream()
  let assert Ok(0x1fa7) =
    file_stream.position(fs, file_stream.BeginningOfFile(0x1fa7))

  value.read(fs, serial_type.Text(16))
  |> pprint.format
  |> birdie.snap("First value of first record")
}

pub fn second_value_of_first_record_test() {
  use fs <- sample.stream()
  let assert Ok(0x1fb7) =
    file_stream.position(fs, file_stream.BeginningOfFile(0x1fb7))

  value.read(fs, serial_type.Text(6))
  |> pprint.format
  |> birdie.snap("Second value of first record")
}

pub fn int8_in_record_test() {
  use fs <- sample.stream()
  let assert Ok(0x2ff3) =
    file_stream.position(fs, file_stream.BeginningOfFile(0x2ff3))

  value.read(fs, serial_type.Int8)
  |> pprint.format
  |> birdie.snap("Int8 in record")
}
