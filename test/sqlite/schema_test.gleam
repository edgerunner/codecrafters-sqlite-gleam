import birdie
import glacier/should
import pprint
import sample
import sqlite/schema

pub fn sample_schema_test() {
  use fs <- sample.stream(100)
  schema.read(fs)
  |> pprint.format
  |> birdie.snap("Sample schema dump")
}

pub fn column_index_test() {
  use fs <- sample.stream(100)
  schema.read(fs)
  |> schema.get("apples")
  |> should.be_ok
  |> schema.get_column_index("name")
  |> should.be_ok
  |> should.equal(1)
}
