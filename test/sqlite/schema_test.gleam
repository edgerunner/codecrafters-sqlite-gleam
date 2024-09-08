import birdie
import glacier/should
import pprint
import sample
import sqlite/schema

pub fn sample_schema_test() {
  use db <- sample.db(sample.fruits)
  schema.read(from: db)
  |> pprint.format
  |> birdie.snap("Sample schema dump")
}

pub fn superheroes_schema_test() {
  use db <- sample.db(sample.superheroes)
  schema.read(from: db)
  |> pprint.format
  |> birdie.snap("superheroes_schema")
}

pub fn companies_schema_test() {
  use db <- sample.db(sample.companies)
  schema.read(from: db)
  |> pprint.format
  |> birdie.snap("companies_schema")
}

pub fn column_index_test() {
  use db <- sample.db(sample.fruits)
  schema.read(from: db)
  |> schema.get_table(called: "apples")
  |> should.be_ok
  |> schema.get_column_index(for: "name")
  |> should.be_ok
  |> should.equal(1)
}
