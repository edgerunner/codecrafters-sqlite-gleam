import gleam/list
import sql.{type ColumnDefinition}
import sqlite/cell
import sqlite/db.{type DB}
import sqlite/value

pub type Schema {
  Schema(tables: List(Table), indices: List(Index))
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

pub type Index {
  Index(
    name: String,
    tbl_name: String,
    root_page: Int,
    sql: String,
    columns: List(String),
  )
}

pub fn read(from db: DB) -> Schema {
  use schema, cell <- list.fold(
    from: Schema([], []),
    over: cell.read_all(from: db, in: 1),
  )
  let assert cell.TableLeafCell(record:, ..) = cell
  let assert [
    value.Text(entry),
    value.Text(name),
    value.Text(tbl_name),
    value.Integer(root_page),
    value.Text(sql),
  ] = record
  case entry {
    "table" -> {
      let assert Ok(sql.Create(sql.Table(columns:, ..))) = sql.parse(sql)
      let table = Table(name:, tbl_name:, root_page:, sql:, columns:)
      Schema(..schema, tables: [table, ..schema.tables])
    }
    "index" -> {
      let assert Ok(sql.Create(sql.Index(columns:, ..))) = sql.parse(sql)
      let index = Index(name:, tbl_name:, root_page:, sql:, columns:)
      Schema(..schema, indices: [index, ..schema.indices])
    }
    _ -> panic as "Invalid schema entry"
  }
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
