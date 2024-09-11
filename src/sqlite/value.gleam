import file_streams/file_stream.{type FileStream}
import gleam/float
import gleam/int
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/result
import gleam/string
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

/// Compares two `Value`s as described in SQLite
/// [record sort order](https://www.sqlite.org/fileformat.html#record_sort_order)
pub fn compare(left: Value, right: Value) -> Order {
  case left, right {
    Null, Null -> Eq
    Integer(l), Integer(r) -> int.compare(l, r)
    Floating(l), Floating(r) -> float.compare(l, r)
    Text(l), Text(r) -> string.compare(l, r)
    Blob(l), Blob(r) if l == r -> Eq
    Integer(il), Floating(fr) -> int.to_float(il) |> float.compare(fr)
    Floating(fl), Integer(ir) -> int.to_float(ir) |> float.compare(fl, _)
    Null, _ -> Lt
    _, Null -> Gt
    Integer(_), _ -> Lt
    _, Integer(_) -> Gt
    Floating(_), _ -> Lt
    _, Floating(_) -> Gt
    Text(_), _ -> Lt
    _, Text(_) -> Gt
    _, _ -> Lt
  }
}
