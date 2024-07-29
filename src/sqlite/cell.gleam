import file_streams/file_stream.{type FileStream}
import sqlite/record
import sqlite/value.{type Value}
import varint

pub type Cell {
  Cell(payload_size: Int, row_id: Int, record: List(Value))
}

pub fn read(fs: FileStream) -> Cell {
  let payload_size = varint.read(fs)
  let row_id = varint.read(fs)
  let record = record.read(fs)
  Cell(payload_size, row_id, record)
}

pub fn read_at(pos: Int, fs: FileStream) -> Cell {
  let assert Ok(_) = file_stream.position(fs, file_stream.BeginningOfFile(pos))
  read(fs)
}
