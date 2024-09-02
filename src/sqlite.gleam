import argv
import file_streams/file_open_mode
import file_streams/file_stream
import gleam/bit_array
import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import sql.{Count, Select}
import sqlite/db
import sqlite/page
import sqlite/schema
import sqlite/table
import sqlite/value

pub fn main() {
  let args = argv.load().arguments

  // Uncomment this to pass the first stage
  case args {
    [database_file_path, ".dbinfo", ..] -> {
      let assert Ok(fs) =
        file_stream.open(database_file_path, [file_open_mode.Read])

      let db = db.read(fs)
      let schema = schema.read(db)

      io.print("database page size: ")
      io.println(int.to_string(db.page_size))

      io.print("number of tables: ")
      schema.tables
      |> list.length
      |> int.to_string
      |> io.println
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
          let root_page = page.read(from: db, page: table.root_page)

          root_page.pointers
          |> list.length
          |> int.to_string
          |> io.println
        }
        Select(sql.Columns(columns), table_name, where) -> {
          let assert Ok(from_table) = table.read(from: db, name: table_name)

          let filter = case where {
            sql.Everything -> fn(_) { True }
            sql.Equality(column, compare_value) -> {
              fn(row) {
                let assert Ok(value) = dict.get(row, column)
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

          table.filter(from_table, filter)
          |> table.select(columns:)
          |> table.rows
          |> list.each(fn(row) {
            list.map(row, value.to_string)
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
