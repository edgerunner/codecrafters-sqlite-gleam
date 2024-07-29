import birdie
import pprint
import sample
import sqlite/db_header

pub fn header_read_test() {
  use file <- sample.stream(0)

  db_header.read(file)
  |> pprint.with_config(pprint.Config(
    pprint.Unstyled,
    pprint.KeepBitArrays,
    pprint.Labels,
  ))
  |> birdie.snap("Sample header")
}
