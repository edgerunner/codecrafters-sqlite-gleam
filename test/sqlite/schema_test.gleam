import birdie
import pprint
import sample
import sqlite/schema

pub fn sample_schema_test() {
  use fs <- sample.stream(100)
  schema.read(fs)
  |> pprint.format
  |> birdie.snap("Sample schema dump")
}
