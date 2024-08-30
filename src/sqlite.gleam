import argv
import file_streams/file_open_mode
import file_streams/file_stream
import gleam/int.{to_string}
import gleam/io
import gleam/list
import gleam/string
import sql/parser.{Count, Select}
import sqlite/db_header
import sqlite/page_header
import sqlite/schema

pub fn main() {
  let args = argv.load().arguments

  // Uncomment this to pass the first stage
  case args {
    [database_file_path, ".dbinfo", ..] -> {
      let assert Ok(fs) =
        file_stream.open(database_file_path, [file_open_mode.Read])

      let db_header = db_header.read(fs)
      let schema_page_header = page_header.read(fs)

      io.print("database page size: ")
      io.println(to_string(db_header.page_size))

      io.print("number of tables: ")
      io.println(to_string(schema_page_header.cells))
    }
    [database_file_path, ".tables", ..] -> {
      let assert Ok(fs) =
        file_stream.open(database_file_path, [file_open_mode.Read])

      let _db_header = db_header.read(fs)
      let schema = schema.read(fs)

      schema.tables
      |> list.map(fn(table) { table.name })
      |> string.join(" ")
      |> io.println
    }
    [database_file_path, sql_string, ..] -> {
      let assert Ok(fs) =
        file_stream.open(database_file_path, [file_open_mode.Read])
      let db_header = db_header.read(fs)
      let schema = schema.read(fs)
      let assert Ok(sql) = parser.parse(sql_string)

      case sql {
        Select(Count(_), table_name) -> {
          let assert Ok(table) =
            schema.get_table(called: table_name, from: schema)
          let table_offset =
            page_header.offset(table.root_page, db_header.page_size)
          let assert Ok(_) =
            file_stream.position(fs, file_stream.BeginningOfFile(table_offset))
          let root_page_header = page_header.read(fs)

          root_page_header.pointers
          |> list.length
          |> int.to_string
          |> io.println
        }
        Select(parser.Fields(_), _) -> todo
        parser.CreateTable(_, _) -> {
          io.println_error("ERROR: Table creation not implemented yet")
        }
      }
    }
    _ -> {
      io.println("Unknown command")
    }
  }
}
