import birdie
import glacier/should
import pprint
import sql

pub fn select_count_star_from_apples_test() {
  "SELECT COUNT(*) FROM apples"
  |> sql.parse
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("select_count_star_from_apples")
}

pub fn select_count_color_from_apples_test() {
  "SELECT COUNT(color) FROM apples"
  |> sql.parse
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("select_count_color_from_apples")
}

pub fn select_name_from_apples_test() {
  "SELECT name FROM apples"
  |> sql.parse
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("select_name_from_apples")
}

pub fn select_name_from_apples_where_color_is_yellow_test() {
  "SELECT name, color FROM apples WHERE color = 'Yellow'"
  |> sql.parse
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("select_name_from_apples_where_color_is_yellow")
}

pub fn select_name_color_from_apples_test() {
  "SELECT name, color FROM apples"
  |> sql.parse
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("select_name_color_from_apples")
}

pub fn create_table_test() {
  "CREATE TABLE apples\n(\n\tid integer primary key autoincrement,\n\tname text,\n\tcolor text\n)"
  |> sql.parse
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("create_table")
}

pub fn create_index_test() {
  "CREATE INDEX idx_companies_country\n\ton companies (country)"
  |> sql.parse
  |> should.be_ok
  |> pprint.format
  |> birdie.snap("create_index")
}
