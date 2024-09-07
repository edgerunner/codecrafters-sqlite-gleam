import gleam/string
import party.{type ParseError, type Parser, do, try}

pub type SQL {
  Select(Select, from: String, where: Where)
  Create(Create)
}

pub type Select {
  Columns(List(String))
  Count(List(String))
}

pub type Where {
  Everything
  Equality(column: String, value: String)
}

pub type Create {
  Table(name: String, columns: List(ColumnDefinition))
}

pub type Error {
  UnknownCommand(String)
}

pub type ColumnDefinition {
  ColumnDefinition(
    name: String,
    affinity: ColumnAffinity,
    primary_key: PrimaryKey,
    not_null: Bool,
  )
}

pub type ColumnAffinity {
  Text
  Integer
  Numeric
  Real
  Blob
}

pub type PrimaryKey {
  NotPrimaryKey
  PrimaryKey
  PrimaryWithAutoIncrement
}

pub fn parse(input: String) -> Result(SQL, ParseError(Error)) {
  party.go(sql(), input)
}

pub fn sql() -> Parser(SQL, Error) {
  party.choice([select(), create_table()])
}

fn select() -> Parser(SQL, Error) {
  use _ <- do(party.all([command("SELECT"), space1()]))
  use selection <- do(party.either(count(), columns() |> party.map(Columns)))
  use _ <- do(party.all([space1(), command("FROM"), space1()]))
  use from <- do(identifier())
  use where <- do(party.either(where_clause(), party.return(Everything)))
  party.return(Select(selection, from:, where:))
}

fn count() -> Parser(Select, Error) {
  use _ <- do(party.all([command("COUNT"), space()]))
  use fields <- do(parens(columns()))
  party.return(Count(fields))
}

fn columns() -> Parser(List(String), Error) {
  use columns <- do(party.either(
    token("*") |> as_value([]),
    party.sep(identifier(), by: list_comma()),
  ))
  party.return(columns)
}

fn where_clause() -> Parser(Where, Error) {
  use _ <- do(party.all([space1(), command("WHERE"), space1()]))
  use column <- do(identifier())
  use _ <- do(party.all([space(), token("="), space()]))
  use value <- do(quoted(party.satisfy(fn(_) { True })))
  party.return(Equality(column:, value:))
}

fn create_table() -> Parser(SQL, Error) {
  use _ <- do(
    party.all([command("CREATE"), space1(), command("TABLE"), space1()]),
  )
  use name <- do(party.either(quoted(identifier()), identifier()))
  use _ <- do(space())
  use columns <- do(parens(column_defs()))
  party.return(Create(Table(name:, columns:)))
}

fn column_defs() -> Parser(List(ColumnDefinition), Error) {
  use defs <- do(party.sep(column_def(), by: list_comma()))
  party.return(defs)
}

fn column_def() -> Parser(ColumnDefinition, Error) {
  use name <- do(identifier())
  use affinity <- do(affinity())
  use primary_key <- do(primary_key())
  use not_null <- do(not_null())
  party.return(ColumnDefinition(name:, affinity:, primary_key:, not_null:))
}

fn affinity() -> Parser(ColumnAffinity, Error) {
  {
    use _ <- do(space1())
    party.choice([
      command("integer") |> as_value(Integer),
      command("text") |> as_value(Text),
      command("float") |> as_value(Real),
    ])
  }
  |> party.either(party.return(Blob))
}

fn primary_key() -> Parser(PrimaryKey, Error) {
  let autoincrement = fn() {
    use _ <- do(space1())
    command("AUTOINCREMENT") |> as_value(PrimaryWithAutoIncrement)
  }
  let primary = fn() {
    use _ <- do(
      party.all([space1(), command("PRIMARY"), space1(), command("KEY")]),
    )
    party.either(autoincrement(), party.return(PrimaryKey))
  }
  party.either(primary(), party.return(NotPrimaryKey))
}

fn not_null() -> Parser(Bool, Error) {
  party.either(
    party.all([space1(), command("NOT"), space1(), command("NULL")])
      |> as_value(True),
    party.return(False),
  )
}

fn command(token: String) -> Parser(Nil, Error) {
  use command_string <- try(party.many1_concat(party.letter()))
  case string.uppercase(token) == string.uppercase(command_string) {
    False -> Error(UnknownCommand(command_string))
    True -> Ok(Nil)
  }
}

fn identifier() {
  use first <- do(party.letter())
  use rest <- do(
    party.many_concat(party.either(party.alphanum(), party.string("_"))),
  )
  party.return(first <> rest)
}

fn parens(parser: Parser(a, e)) -> Parser(a, e) {
  use _ <- do(party.all([token("("), space()]))
  use inner <- do(parser)
  use _ <- do(party.all([space(), token(")")]))
  party.return(inner)
}

fn list_comma() -> Parser(Nil, e) {
  use _ <- do(party.all([space(), token(","), space()]))
  party.return(Nil)
}

fn token(t: String) -> Parser(Nil, e) {
  use _ <- do(party.string(t))
  party.return(Nil)
}

fn space() -> Parser(Nil, e) {
  use _ <- do(party.many(spacer()))
  party.return(Nil)
}

fn space1() -> Parser(Nil, e) {
  use _ <- do(party.many1(spacer()))
  party.return(Nil)
}

fn spacer() -> Parser(Nil, e) {
  use _ <- do(
    party.choice([party.whitespace1(), party.string("\n"), party.string("\t")]),
  )
  party.return(Nil)
}

fn as_value(prev: Parser(nil, e), value: a) -> Parser(a, e) {
  use _ <- party.map(prev)
  value
}

fn quoted(parser: Parser(String, e)) -> Parser(String, e) {
  use quote <- do(party.either(party.string("'"), party.string("\"")))
  use characters <- do(party.until(parser, token(quote)))
  string.concat(characters) |> party.return
}
