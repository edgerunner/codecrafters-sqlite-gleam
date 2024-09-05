import birdie
import gleam/regex
import pprint
import sample
import sqlite/db

pub fn db_header_read_test() {
  use file <- sample.stream(sample.fruits, 0)

  db.read(file)
  |> pprint.format
  |> mask_erl_process_ids
  |> birdie.snap("db_header_read")
}

fn mask_erl_process_ids(input) {
  let assert Ok(process_id) = regex.from_string("//erl\\(<[.0-9]+>\\)")
  regex.replace(each: process_id, in: input, with: "//erl(<process>)")
}
