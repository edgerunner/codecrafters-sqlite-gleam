import glacier/should
import sql/parser

pub fn select_count_star_from_apples_test() {
  "SELECT COUNT(*) FROM apples"
  |> parser.parse
  |> should.be_ok
  |> should.equal(parser.Select(parser.Count([]), from: "apples"))
}

pub fn select_name_from_apples_test() {
  "SELECT name FROM apples"
  |> parser.parse
  |> should.be_ok
  |> should.equal(parser.Select(parser.Fields(["name"]), from: "apples"))
}

pub fn create_table_test() {
  "CREATE TABLE apples\n(\n\tid integer primary key autoincrement,\n\tname text,\n\tcolor text\n)"
  |> parser.parse
  |> should.be_ok
  |> should.equal(
    parser.CreateTable(name: "apples", columns: [
      parser.ColumnDefinition(
        "id",
        parser.Integer,
        parser.PrimaryWithAutoIncrement,
      ),
      parser.ColumnDefinition("name", parser.Text, parser.NotPrimaryKey),
      parser.ColumnDefinition("color", parser.Text, parser.NotPrimaryKey),
    ]),
  )
}
