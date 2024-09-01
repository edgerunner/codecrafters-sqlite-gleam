import file_streams/file_stream.{type FileStream}
import gleam/list
import sqlite/db.{type DB}
import sqlite/page
import sqlite/record
import sqlite/value.{type Value}
import varint

pub type Cell {
  TableLeafCell(payload_size: Int, row_id: Int, record: List(Value))
  TableInteriorCell(left_child_pointer: Int, row_id: Int)
}

pub fn read_all(from db: DB, in page: Int) -> List(Cell) {
  let page = page.read(from: db, page:)
  use pointer <- list.map(page.pointers)
  let assert Ok(_) =
    file_stream.position(db.fs, file_stream.BeginningOfFile(pointer))
  case page.node_type {
    page.Leaf -> read_table_leaf_cell(db.fs)
    page.Interior(..) -> read_table_interior_cell(db.fs)
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
