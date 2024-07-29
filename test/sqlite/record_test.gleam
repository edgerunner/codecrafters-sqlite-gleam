import birdie
import pprint
import sample
import sqlite/record

pub fn read_record_1_test() {
  use fs <- sample.stream(0x2ff6)
  record.read(fs)
  |> pprint.format
  |> birdie.snap("Record 1")
}

pub fn read_record_2_test() {
  use fs <- sample.stream(0x1fa3)
  record.read(fs)
  |> pprint.format
  |> birdie.snap("Record 2")
}
