import birdie
import glacier
import gleam/list
import pprint
import sample
import sqlite/cell
import sqlite/page_header

pub fn main() {
  glacier.main()
}

pub fn sample_schema_dump_test() {
  use fs <- sample.stream(100)
  let schema_page_header = page_header.read(fs)

  schema_page_header.pointers
  |> list.map(cell.read_at(_, fs))
  |> pprint.format
  |> birdie.snap("Sample schema dump")
}
