import birdie
import pprint
import sample
import sqlite/page_header

pub fn first_page_header_test() {
  use fs <- sample.stream(100)

  page_header.read(fs)
  |> pprint.format
  |> birdie.snap("First page header")
}

pub fn second_page_header_test() {
  use fs <- sample.stream(0x1000)

  page_header.read(fs)
  |> pprint.format
  |> birdie.snap("Second page header")
}
