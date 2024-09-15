import gleam/dict.{type Dict}
import gleam/int
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
    page.Interior(right_pointer:) ->
      {
        use table, cell <- list.fold(over: cells, from: table)
        let assert cell.TableInteriorCell(left_child_pointer:, ..) = cell
        traverse_page(db:, page: left_child_pointer, table:)
      }
      |> traverse_page(db:, page: right_pointer, table: _)
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

pub fn get_rows(
  ids ids: List(Int),
  from db: DB,
  name table_name: String,
) -> Result(Table, Nil) {
  use schema <- result.map(schema.read(db) |> schema.get_table(table_name))
  let ids = list.sort(ids, int.compare)
  get_rows_from_page(number: schema.root_page, ids:, db:, results: dict.new()).0
  |> Table(schema:)
}

fn get_rows_from_page(
  number page_number: Int,
  ids ids: List(Int),
  db db: DB,
  results results: Dict(Int, List(Value)),
) -> #(Dict(Int, List(Value)), List(Int)) {
  let cells = cell.read_all(from: db, in: page_number)
  let #(results, ids) = {
    use #(results, ids), cell <- list.fold(over: cells, from: #(results, ids))
    case cell, ids {
      // no more ids to be found, just return
      _, [] -> #(results, [])
      // there's a matching id, drop the id, add the row
      cell.TableLeafCell(row_id:, record:, ..), [id, ..rest] if id == row_id -> #(
        {
          let record_with_id = case record {
            [value.Null, ..rest] -> [value.Integer(row_id), ..rest]
            _ -> record
          }
          dict.insert(results, id, record_with_id)
        },
        rest,
      )
      // mismatched id, just skip and continue
      cell.TableLeafCell(..), [_id, ..] -> #(results, ids)
      // the page max id is smaller, so we skip this page entirely
      cell.TableInteriorCell(row_id:, ..), [id, ..] if row_id < id -> #(
        results,
        ids,
      )
      // page max id is equal or larger than the next id, so the id is possibly in it.
      // we go down to search
      cell.TableInteriorCell(left_child_pointer:, ..), [_, ..] ->
        get_rows_from_page(number: left_child_pointer, ids:, db:, results:)
      // we shouldn't encounter index cells in a table page. This is an error.
      _, _ -> panic as "Index cells in a table page"
    }
  }
  case ids, page.read(db, page_number) {
    // read the rightmost child page if there still is more ids to find
    [_, ..], page.Page(node_type: page.Interior(right_pointer:), ..) ->
      get_rows_from_page(number: right_pointer, ids:, db:, results:)
    _, _ -> #(results, ids)
  }
}
