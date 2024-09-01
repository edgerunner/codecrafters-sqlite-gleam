import birdie
import pprint
import sample
import sqlite/db

pub fn db_header_read_test() {
  use file <- sample.stream(0)

  db.read(file)
  |> pprint.with_config(pprint.Config(
    pprint.Unstyled,
    pprint.KeepBitArrays,
    pprint.Labels,
  ))
  |> birdie.snap("db_header_read")
}
