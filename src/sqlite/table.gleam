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

pub fn select(from table: Table, columns columns: List(String)) -> Table {
  let column_indices =
    list.filter_map(columns, schema.get_column_index(from: table.schema, for: _))

  let rows =
    dict.map_values(table.rows, with: fn(_id, row) {
      use column_index <- list.filter_map(column_indices)
      row |> list.drop(column_index) |> list.first
    })

  Table(..table, rows:)
}

pub fn filter(
  from table: Table,
  with filter_function: fn(Dict(String, Value)) -> Bool,
) -> Table {
  let rows =
    dict.filter(table.rows, fn(_id, row) {
      list.map2(table.schema.columns, row, fn(def, value) { #(def.name, value) })
      |> dict.from_list
      |> filter_function
    })
  Table(..table, rows:)
}
