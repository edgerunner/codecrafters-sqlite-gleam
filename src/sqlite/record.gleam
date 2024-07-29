import file_streams/file_stream.{type FileStream}
import gleam/list
import sqlite/record_header
import sqlite/value.{type Value}

pub fn read(fs: FileStream) -> List(Value) {
  record_header.read(fs)
  |> list.map(value.read(fs, _))
}
