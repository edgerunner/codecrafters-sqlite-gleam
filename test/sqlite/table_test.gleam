import birdie
import glacier/should
import gleam/dict
import gleam/result
import pprint
import sample
import sqlite/index
import sqlite/schema
import sqlite/table
import sqlite/value

pub fn apples_table_test() {
  use db <- sample.db(sample.fruits)
  table.read(from: db, name: "apples")
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("apples_table")
}

pub fn select_apples_test() {
  use db <- sample.db(sample.fruits)
  table.read(from: db, name: "apples")
  |> should.be_ok
  |> table.select(["name"])
  |> pprint.format
  |> birdie.snap("select_apples")
}

pub fn filter_red_apples_test() {
  use db <- sample.db(sample.fruits)
  table.read(from: db, name: "apples")
  |> should.be_ok
  |> table.filter(fn(row) {
    let assert Ok(value.Text(color)) = dict.get(row, "color")
    color == "Red"
  })
  |> pprint.format
  |> birdie.snap("filter_red_apples")
}

pub fn pink_eyed_superheroes_table_test() {
  use db <- sample.db(sample.superheroes)
  table.read(from: db, name: "superheroes")
  |> should.be_ok
  |> table.filter(fn(row) {
    dict.get(row, "eye_color")
    |> result.map(fn(color) { color == value.Text("Pink Eyes") })
    |> result.unwrap(False)
  })
  |> pprint.format
  |> birdie.snap("pink_eyed_superheroes_table")
}

pub fn get_rows_companies_from_andorra_test() {
  use db <- sample.db(sample.companies)

  schema.read(db)
  |> schema.get_index(on: "companies", for: "country")
  |> should.be_ok
  |> index.search(in: db, on: _, for: value.Text("andorra"))
  |> table.get_rows(from: db, name: "companies")
  |> should.be_ok
  |> table.rows
  |> pprint.format
  |> birdie.snap("get_rows_companies_from_andorra")
}
