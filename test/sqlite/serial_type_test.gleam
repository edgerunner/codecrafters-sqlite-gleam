import gleeunit/should
import sqlite/serial_type

pub fn text_from_int_test() {
  serial_type.from_int(27)
  |> should.equal(serial_type.Text(7))
}

pub fn length_of_text_test() {
  serial_type.from_int(27)
  |> serial_type.bytes
  |> should.equal(7)
}

pub fn blob_from_int_test() {
  serial_type.from_int(26)
  |> should.equal(serial_type.Blob(7))
}

pub fn length_of_blob_test() {
  serial_type.from_int(26)
  |> serial_type.bytes
  |> should.equal(7)
}
