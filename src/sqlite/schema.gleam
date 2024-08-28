import file_streams/file_stream.{type FileStream}
import gleam/list
import sqlite/cell
import sqlite/page_header
import sqlite/value

pub type Schema {
  Schema(tables: List(Table))
}

pub type Table {
  Table(name: String, tbl_name: String, root_page: Int, sql: String)
}

pub fn read(fs: FileStream) -> Schema {
  let schema_page_header = page_header.read(fs)
  schema_page_header.pointers
  |> list.map(fn(pos) {
    let cell = cell.read_at(pos, fs)
    let assert [
      value.Text("table"),
      value.Text(name),
      value.Text(tbl_name),
      value.Integer(root_page),
      value.Text(sql),
    ] = cell.record
    Table(name: name, tbl_name: tbl_name, root_page: root_page, sql: sql)
  })
  |> Schema
}

pub fn get(schema: Schema, name: String) -> Result(Table, Nil) {
  list.find(schema.tables, fn(table) { table.name == name })
}
