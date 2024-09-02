import birdie
import pprint
import sample
import sqlite/page

pub fn first_page_test() {
  use db <- sample.db(sample.fruits)

  page.read(from: db, page: 1)
  |> pprint.format
  |> birdie.snap("First page header")
}

pub fn second_page_test() {
  use db <- sample.db(sample.fruits)

  page.read(from: db, page: 2)
  |> pprint.format
  |> birdie.snap("Second page header")
}
