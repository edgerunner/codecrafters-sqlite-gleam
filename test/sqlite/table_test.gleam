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

pub fn select_apples_test() {
  use db <- sample.db()
  table.read(from: db, name: "apples")
  |> should.be_ok
  |> table.select(["name"])
  |> pprint.format
  |> birdie.snap("select_apples")
}
