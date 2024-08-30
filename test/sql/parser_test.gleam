import birdie
import glacier/should
import pprint
import sql/parser

pub fn select_count_star_from_apples_test() {
  "SELECT COUNT(*) FROM apples"
  |> parser.parse
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("select_count_star_from_apples")
}

pub fn select_count_color_from_apples_test() {
  "SELECT COUNT(color) FROM apples"
  |> parser.parse
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("select_count_color_from_apples")
}

pub fn select_name_from_apples_test() {
  "SELECT name FROM apples"
  |> parser.parse
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("select_name_from_apples")
}

pub fn select_name_color_from_apples_test() {
  "SELECT name, color FROM apples"
  |> parser.parse
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("select_name_color_from_apples")
}

pub fn create_table_test() {
  "CREATE TABLE apples\n(\n\tid integer primary key autoincrement,\n\tname text,\n\tcolor text\n)"
  |> parser.parse
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("create_table")
}
