import birdie
import pprint
import sample
import sqlite/cell
import sqlite/db_header

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

pub fn read_all_page1_test() {
  use fs <- sample.stream(0x0000)
  db_header.read(fs)
  |> cell.read_all(fs, in: 1, from: _)
  |> pprint.format
  |> birdie.snap("read_all_page1")
}

pub fn read_all_page2_test() {
  use fs <- sample.stream(0x0000)
  db_header.read(fs)
  |> cell.read_all(fs, in: 2, from: _)
  |> pprint.format
  |> birdie.snap("read_all_page2")
}

pub fn read_all_page3_test() {
  use fs <- sample.stream(0x0000)
  db_header.read(fs)
  |> cell.read_all(fs, in: 3, from: _)
  |> pprint.format
  |> birdie.snap("read_all_page3")
}

pub fn read_all_page4_test() {
  use fs <- sample.stream(0x0000)
  db_header.read(fs)
  |> cell.read_all(fs, in: 4, from: _)
  |> pprint.format
  |> birdie.snap("read_all_page4")
}
