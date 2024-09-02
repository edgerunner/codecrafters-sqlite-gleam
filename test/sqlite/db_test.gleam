import birdie
import pprint
import sample
import sqlite/db

pub fn db_header_read_test() {
  use file <- sample.stream(sample.fruits, 0)

  db.read(file)
  |> pprint.format
  |> birdie.snap("db_header_read")
}
