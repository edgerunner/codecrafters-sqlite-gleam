import argv
import file_streams/file_open_mode
import file_streams/file_stream
import gleam/bit_array
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import sql.{Count, Select}
import sqlite/cell
import sqlite/db
import sqlite/page_header
import sqlite/schema
import sqlite/value

pub fn main() {
  let args = argv.load().arguments

  // Uncomment this to pass the first stage
  case args {
    [database_file_path, ".dbinfo", ..] -> {
      let assert Ok(fs) =
        file_stream.open(database_file_path, [file_open_mode.Read])

      let db = db.read(fs)
      let schema_page_header = page_header.read(fs)

      io.print("database page size: ")
      io.println(int.to_string(db.page_size))

      io.print("number of tables: ")
      io.println(int.to_string(schema_page_header.cells))
    }
    [database_file_path, ".tables", ..] -> {
      let assert Ok(fs) =
        file_stream.open(database_file_path, [file_open_mode.Read])

      let db = db.read(fs)
      let schema = schema.read(from: db)

      schema.tables
      |> list.map(fn(table) { table.name })
      |> string.join(" ")
      |> io.println
    }
    [database_file_path, sql_string, ..] -> {
      let assert Ok(fs) =
        file_stream.open(database_file_path, [file_open_mode.Read])
      let db = db.read(fs)
      let schema = schema.read(from: db)
      let assert Ok(sql) = sql.parse(sql_string)

      case sql {
        Select(Count(_), table_name, _) -> {
          let assert Ok(table) =
            schema.get_table(called: table_name, from: schema)
          let table_offset = page_header.offset(table.root_page, db.page_size)
          let assert Ok(_) =
            file_stream.position(fs, file_stream.BeginningOfFile(table_offset))
          let root_page_header = page_header.read(fs)

          root_page_header.pointers
          |> list.length
          |> int.to_string
          |> io.println
        }
        Select(sql.Columns(columns), table_name, where) -> {
          let assert Ok(table) =
            schema.get_table(called: table_name, from: schema)
          let column_indices =
            list.filter_map(columns, schema.get_column_index(
              from: table,
              for: _,
            ))
          let filter = case where {
            sql.Everything -> fn(_) { True }
            sql.Equality(column, compare_value) -> {
              let assert Ok(column_index) =
                schema.get_column_index(from: table, for: column)
              fn(record) {
                let assert Ok(value) =
                  record |> list.drop(column_index) |> list.first
                case value {
                  value.Null -> False
                  value.Text(text) -> text == compare_value
                  value.Integer(integer) ->
                    compare_value
                    |> int.parse
                    |> result.map(fn(parsed) { parsed == integer })
                    |> result.unwrap(False)
                  value.Floating(floating) ->
                    compare_value
                    |> float.parse
                    |> result.map(fn(parsed) { parsed == floating })
                    |> result.unwrap(False)
                  value.Blob(blob) ->
                    compare_value
                    |> bit_array.from_string
                    == blob
                }
              }
            }
          }

          cell.read_all(from: db, in: table.root_page)
          |> list.filter_map(fn(cell) {
            case cell {
              cell.TableLeafCell(record:, ..) -> Ok(record)
              _ -> Error(Nil)
            }
          })
          |> list.filter(filter)
          |> list.each(fn(record) {
            column_indices
            |> list.filter_map(fn(column_index) {
              record |> list.drop(column_index) |> list.first
            })
            |> list.map(value.to_string)
            |> string.join("|")
            |> io.println
          })
        }
        sql.CreateTable(_, _) -> {
          io.println_error("ERROR: Table creation not implemented yet")
        }
      }
    }
    _ -> {
      io.println("Unknown command")
    }
  }
}
