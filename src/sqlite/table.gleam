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
  traverse_page(
    db:,
    page: schema.root_page,
    table: Table(rows: dict.new(), schema:),
  )
}

fn traverse_page(db db: DB, page page_number: Int, table table: Table) {
  let page = page.read(from: db, page: page_number)
  let cells = cell.read_all(from: db, in: page_number)
  case page.node_type {
    page.Leaf -> add_rows_to_table(table, from: cells)
    page.Interior(right_pointer:) -> {
      use table, cell <- list.fold(over: cells, from: table)
      let assert cell.TableInteriorCell(left_child_pointer:, ..) = cell
      traverse_page(db:, page: left_child_pointer, table:)
    }
    // |> case right_pointer {
    //   x if x > 1 -> traverse_page(db:, page: right_pointer, table: _)
    //   _ -> fn(table) { table }
    // }
  }
}

fn add_rows_to_table(table: Table, from cells: List(Cell)) -> Table {
  let Table(rows:, ..) = table
  list.fold(over: cells, from: rows, with: fn(rows, cell) {
    let assert cell.TableLeafCell(row_id:, record:, ..) = cell
    let record_with_id = case record {
      [value.Null, ..rest] -> [value.Integer(row_id), ..rest]
      _ -> record
    }
    dict.insert(into: rows, for: row_id, insert: record_with_id)
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

pub fn rows(table: Table) -> List(List(Value)) {
  dict.values(table.rows)
}
