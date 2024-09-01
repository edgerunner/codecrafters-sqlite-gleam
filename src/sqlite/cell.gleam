import file_streams/file_stream.{type FileStream}
import gleam/list
import sqlite/db.{type DB}
import sqlite/page_header
import sqlite/record
import sqlite/value.{type Value}
import varint

pub type Cell {
  TableLeafCell(payload_size: Int, row_id: Int, record: List(Value))
  TableInteriorCell(left_child_pointer: Int, row_id: Int)
}

pub fn read_all(fs: FileStream, from db: DB, in page_number: Int) -> List(Cell) {
  let assert Ok(_) =
    page_header.offset(db.page_size, page_number:)
    |> file_stream.BeginningOfFile
    |> file_stream.position(fs, _)
  let page_header = page_header.read(fs)
  use pointer <- list.map(page_header.pointers)
  let assert Ok(_) =
    file_stream.position(
      fs,
      file_stream.BeginningOfFile(
        db.page_size * page_number - db.page_size + pointer,
      ),
    )
  case page_header {
    page_header.LeafTable(..) -> read_table_leaf_cell(fs)
    page_header.InteriorTable(..) -> read_table_interior_cell(fs)
    _ -> panic as "Index pages aren't yet implemented"
  }
}

fn read_table_interior_cell(fs: FileStream) -> Cell {
  let assert Ok(left_child_pointer) = file_stream.read_int32_be(fs)
  let row_id = varint.read(fs)
  TableInteriorCell(left_child_pointer:, row_id:)
}

fn read_table_leaf_cell(fs: FileStream) -> Cell {
  let payload_size = varint.read(fs)
  let row_id = varint.read(fs)
  let record = record.read(fs)
  TableLeafCell(payload_size:, row_id:, record:)
}
