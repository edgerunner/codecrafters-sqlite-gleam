import birdie
import pprint
import sample
import sqlite/cell

pub fn read_cell_1_test() {
  use fs <- sample.stream(0x2ff4)
  cell.read(fs)
  |> pprint.format
  |> birdie.snap("Cell 1")
}

pub fn read_cell_2_test() {
  use fs <- sample.stream(0x1fa1)
  cell.read(fs)
  |> pprint.format
  |> birdie.snap("Cell 2")
}
