import file_streams/file_stream.{type FileStream}
import gleam/list
import sqlite/db_header.{type Header}
import sqlite/page_header
import sqlite/record
import sqlite/value.{type Value}
import varint

pub type Cell {
  Cell(payload_size: Int, row_id: Int, record: List(Value))
}

pub fn read_all(
  fs: FileStream,
  from db: Header,
  in page_number: Int,
) -> List(Cell) {
  let page_offset = page_header.offset(db.page_size, page_number:)
  let assert Ok(_) =
    page_offset
    |> file_stream.BeginningOfFile
    |> file_stream.position(fs, _)
  let page_header = page_header.read(fs)
  use pointer <- list.map(page_header.pointers)
  let assert Ok(_) =
    file_stream.position(fs, file_stream.BeginningOfFile(page_offset + pointer))
  read(fs)
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
