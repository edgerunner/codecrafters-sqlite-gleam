import birdie
import glacier/should
import pprint
import sample
import sqlite/table

pub fn apples_table_test() {
  use db <- sample.db()
  table.read(from: db, name: "apples")
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("apples_table")
}
