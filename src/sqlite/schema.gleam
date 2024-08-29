import file_streams/file_stream.{type FileStream}
import gleam/list
import sql/parser.{type ColumnDefinition}
import sqlite/cell
import sqlite/page_header
import sqlite/value

pub type Schema {
  Schema(tables: List(Table))
}

pub type Table {
  Table(
    name: String,
    tbl_name: String,
    root_page: Int,
    sql: String,
    columns: List(ColumnDefinition),
  )
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

    let assert Ok(parser.CreateTable(columns: columns, ..)) = parser.parse(sql)

    Table(
      name: name,
      tbl_name: tbl_name,
      root_page: root_page,
      sql: sql,
      columns: columns,
    )
  })
  |> Schema
}

pub fn get_table(from schema: Schema, called name: String) -> Result(Table, Nil) {
  list.find(schema.tables, fn(table) { table.name == name })
}

pub fn get_column_index(from table: Table, for name: String) -> Result(Int, Nil) {
  use outcome, column, index <- list.index_fold(
    over: table.columns,
    from: Error(Nil),
  )
  case outcome, column.name == name {
    Error(_), True -> Ok(index)
    _, _ -> outcome
  }
}
