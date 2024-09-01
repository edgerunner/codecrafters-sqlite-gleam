import birdie
import pprint
import sample
import sqlite/cell

pub fn read_all_page1_test() {
  use db <- sample.db()
  cell.read_all(in: 1, from: db)
  |> pprint.format
  |> birdie.snap("read_all_page1")
}

pub fn read_all_page2_test() {
  use db <- sample.db()
  cell.read_all(in: 2, from: db)
  |> pprint.format
  |> birdie.snap("read_all_page2")
}

pub fn read_all_page3_test() {
  use db <- sample.db()
  cell.read_all(in: 3, from: db)
  |> pprint.format
  |> birdie.snap("read_all_page3")
}

pub fn read_all_page4_test() {
  use db <- sample.db()
  cell.read_all(in: 4, from: db)
  |> pprint.format
  |> birdie.snap("read_all_page4")
}
