import birdie
import glacier/should
import gleam/dict
import pprint
import sample
import sqlite/table
import sqlite/value

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

pub fn filter_red_apples_test() {
  use db <- sample.db()
  table.read(from: db, name: "apples")
  |> should.be_ok
  |> table.filter(fn(row) {
    let assert Ok(value.Text(color)) = dict.get(row, "color")
    color == "Red"
  })
  |> pprint.format
  |> birdie.snap("filter_red_apples")
}
