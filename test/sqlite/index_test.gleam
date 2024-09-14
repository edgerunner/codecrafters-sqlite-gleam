import birdie
import glacier/should
import pprint
import sample
import sqlite/index
import sqlite/schema
import sqlite/value

pub fn companies_country_index_test() {
  use db <- sample.db(sample.companies)

  schema.read(db)
  |> schema.get_index(on: "companies", for: "country")
  |> should.be_ok
  |> index.search(in: db, on: _, for: value.Text("eritrea"))
  |> pprint.format
  |> birdie.snap("companies_country_index")
}
