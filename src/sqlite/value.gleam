import file_streams/file_stream.{type FileStream}
import gleam/float
import gleam/int
import gleam/result
import sqlite/serial_type.{type SerialType}

pub type Value {
  Null
  Integer(Int)
  Floating(Float)
  Blob(BitArray)
  Text(String)
}

pub fn read(fs: FileStream, stype: SerialType) -> Value {
  let assert Ok(value) = case stype {
    serial_type.Null -> Ok(Null)
    serial_type.Zero -> Ok(Integer(0))
    serial_type.One -> Ok(Integer(1))
    serial_type.Int8 -> file_stream.read_int8(fs) |> result.map(Integer)
    serial_type.Int16 -> file_stream.read_int16_be(fs) |> result.map(Integer)
    serial_type.Int24 -> file_stream.read_int32_be(fs) |> result.map(Integer)
    serial_type.Int32 -> file_stream.read_int32_be(fs) |> result.map(Integer)
    serial_type.Int48 -> file_stream.read_int32_be(fs) |> result.map(Integer)
    serial_type.Int64 -> file_stream.read_int64_be(fs) |> result.map(Integer)
    serial_type.Float64 ->
      file_stream.read_float64_be(fs) |> result.map(Floating)
    serial_type.Blob(l) ->
      file_stream.read_bytes_exact(fs, l) |> result.map(Blob)
    serial_type.Text(l) -> file_stream.read_chars(fs, l) |> result.map(Text)
  }
  value
}

pub fn to_string(value: Value) -> String {
  case value {
    Null -> "NULL"
    Integer(i) -> int.to_string(i)
    Floating(f) -> float.to_string(f)
    Blob(_b) -> "BLOB"
    Text(t) -> t
  }
}
