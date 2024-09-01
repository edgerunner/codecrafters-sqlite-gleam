import file_streams/file_stream.{type FileStream}
import gleam/list
import sql.{type ColumnDefinition}
import sqlite/cell
import sqlite/db.{type DB}
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

pub fn read(fs: FileStream, from db: DB) -> Schema {
  cell.read_all(fs, from: db, in: 1)
  |> list.map(fn(cell) {
    let assert cell.TableLeafCell(record:, ..) = cell
    let assert [
      value.Text("table"),
      value.Text(name),
      value.Text(tbl_name),
      value.Integer(root_page),
      value.Text(sql),
    ] = record

    let assert Ok(sql.CreateTable(columns:, ..)) = sql.parse(sql)

    Table(name:, tbl_name:, root_page:, sql:, columns:)
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
