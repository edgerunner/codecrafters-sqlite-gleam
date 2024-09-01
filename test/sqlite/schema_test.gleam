import birdie
import glacier/should
import pprint
import sample
import sqlite/db_header
import sqlite/schema

pub fn sample_schema_test() {
  use fs <- sample.stream(0)
  let db = db_header.read(fs)
  schema.read(fs, from: db)
  |> pprint.format
  |> birdie.snap("Sample schema dump")
}

pub fn column_index_test() {
  use fs <- sample.stream(0)
  let db = db_header.read(fs)
  schema.read(fs, from: db)
  |> schema.get_table(called: "apples")
  |> should.be_ok
  |> schema.get_column_index(for: "name")
  |> should.be_ok
  |> should.equal(1)
}
