import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import sqlite/cell.{type Cell}
import sqlite/db.{type DB}
import sqlite/page
import sqlite/schema
import sqlite/value.{type Value}

pub type Table {
  Table(rows: Dict(Int, List(Value)), schema: schema.Table)
}

pub fn read(from db: DB, name table_name: String) -> Result(Table, Nil) {
  use schema <- result.map(schema.read(db) |> schema.get_table(table_name))
  let root_page = page.read(from: db, page: schema.root_page)
  let root_cells = cell.read_all(from: db, in: schema.root_page)
  case root_page.page_type {
    page.Table ->
      Table(rows: dict.new(), schema:)
      |> add_rows_to_table(root_cells)

    _ -> todo
  }
}

fn add_rows_to_table(table: Table, from cells: List(Cell)) -> Table {
  let Table(rows:, ..) = table
  list.fold(over: cells, from: rows, with: fn(rows, cell) {
    let assert cell.TableLeafCell(row_id:, record:, ..) = cell
    dict.insert(into: rows, for: row_id, insert: record)
  })
  |> fn(rows) { Table(..table, rows:) }
}
