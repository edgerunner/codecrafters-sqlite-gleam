import glacier/should
import sql/parser

pub fn select_count_star_from_apples_test() {
  "SELECT COUNT(*) FROM apples"
  |> parser.parse
  |> should.be_ok
  |> should.equal(parser.Select(parser.Count([]), from: "apples"))
}
