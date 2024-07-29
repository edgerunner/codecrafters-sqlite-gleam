import birdie
import pprint
import sample
import sqlite/record_header

pub fn read_record_header_1_test() {
  use fs <- sample.stream(0x2ff6)
  record_header.read(fs)
  |> pprint.format
  |> birdie.snap("Record header 1")
}

pub fn read_record_header_2_test() {
  use fs <- sample.stream(0x1fa3)
  record_header.read(fs)
  |> pprint.format
  |> birdie.snap("Record header 2")
}
