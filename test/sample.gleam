import file_streams/file_open_mode
import file_streams/file_stream
import sqlite/db

pub opaque type File {
  File(String)
}

pub const fruits = File("sample.db")

pub const superheroes = File("superheroes.db")

pub const companies = File("companies.db")

pub fn stream(
  file: File,
  position: Int,
  test_body: fn(file_stream.FileStream) -> Nil,
) {
  let File(database_file_path) = file
  let assert Ok(fs) =
    file_stream.open(database_file_path, [file_open_mode.Read])
  let assert Ok(_) =
    file_stream.position(fs, file_stream.BeginningOfFile(position))
  test_body(fs)
  let assert Ok(_) = file_stream.close(fs)
}

pub fn db(file: File, test_body: fn(db.DB) -> Nil) {
  use fs <- stream(file, 0)
  db.read(fs) |> test_body
}
