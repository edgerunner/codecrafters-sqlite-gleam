import gleam/string
import party.{type ParseError, type Parser, do, try}

pub type SQL {
  Select(Select, from: String)
  CreateTable(name: String, columns: List(ColumnDefinition))
}

pub type Select {
  Fields(List(String))
  Count(List(String))
}

pub type Error {
  UnknownCommand(String)
}

pub type ColumnDefinition {
  ColumnDefinition(
    name: String,
    affinity: ColumnAffinity,
    primary_key: PrimaryKey,
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
  use selection <- do(party.either(count(), fields() |> party.map(Fields)))
  use _ <- do(party.all([space1(), command("FROM"), space1()]))
  use from <- do(identifier())
  party.return(Select(selection, from:))
}

fn count() -> Parser(Select, Error) {
  use _ <- do(party.all([command("COUNT"), space(), parens(token("*"))]))
  party.return(Count([]))
}

fn fields() -> Parser(List(String), Error) {
  use fields <- do(party.sep(identifier(), by: list_comma()))
  party.return(fields)
}

fn create_table() -> Parser(SQL, Error) {
  use _ <- do(
    party.all([command("CREATE"), space1(), command("TABLE"), space1()]),
  )
  use name <- do(identifier())
  use _ <- do(space())
  use columns <- do(parens(column_defs()))
  party.return(CreateTable(name:, columns:))
}

fn column_defs() -> Parser(List(ColumnDefinition), Error) {
  use defs <- do(party.sep(column_def(), by: list_comma()))
  party.return(defs)
}

fn column_def() -> Parser(ColumnDefinition, Error) {
  use name <- do(identifier())
  use affinity <- do(affinity())
  use primary_key <- do(primary_key())
  party.return(ColumnDefinition(name:, affinity:, primary_key:))
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
