import gleam/string
import party.{type ParseError, type Parser, do, try}

pub type SQL {
  Select(Select, from: String)
}

pub type Select {
  Count(List(String))
}

pub type Error {
  UnknownCommand(String)
}

pub fn parse(input: String) -> Result(SQL, ParseError(Error)) {
  party.go(sql(), input)
}

fn sql() -> Parser(SQL, Error) {
  use select <- do(command("SELECT", Select))
  use _ <- do(party.whitespace1())
  use count <- do(command("COUNT", Count))
  use _ <- do(party.string("(*)"))
  use _ <- do(party.whitespace1())
  use _ <- do(command("FROM", Nil))
  use _ <- do(party.whitespace1())
  use from <- do(identifier())

  party.return(select(count([]), from))
}

fn command(token: String, value: v) -> Parser(v, Error) {
  use command_string <- try(party.many1_concat(party.letter()))
  case string.uppercase(token) == string.uppercase(command_string) {
    False -> Error(UnknownCommand(command_string))
    True -> Ok(value)
  }
}

fn identifier() {
  use first <- do(party.letter())
  use rest <- do(party.many_concat(party.alphanum()))
  party.return(first <> rest)
}
