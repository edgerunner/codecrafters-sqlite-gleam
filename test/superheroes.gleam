//// Do not forget to download the sample databases

import file_streams/file_open_mode
import file_streams/file_stream
import sqlite/db

const database_file_path = "superheroes.db"

pub fn stream(position: Int, test_body: fn(file_stream.FileStream) -> Nil) {
  let assert Ok(fs) =
    file_stream.open(database_file_path, [file_open_mode.Read])
  let assert Ok(_) =
    file_stream.position(fs, file_stream.BeginningOfFile(position))
  test_body(fs)
  let assert Ok(_) = file_stream.close(fs)
}

pub fn db(test_body: fn(db.DB) -> Nil) {
  use fs <- stream(0)
  db.read(fs) |> test_body
}
