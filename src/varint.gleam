import gleam/pair
import gleam/result

pub fn parse(input: BitArray) -> Result(Int, Nil) {
  parse_(input, 0) |> result.map(pair.first)
}

fn parse_(input: BitArray, big: Int) -> Result(#(Int, BitArray), Nil) {
  case input {
    <<0:1, little:unsigned-7, more:bits>> -> Ok(#(big + little, more))
    <<1:1, middle:unsigned-7, more:bits>> ->
      parse_(more, { big + middle } * 128)
    _ -> Error(Nil)
  }
}

pub fn then(
  input: BitArray,
  callback: fn(Int, BitArray) -> Result(a, Nil),
) -> Result(a, Nil) {
  use #(varint, more) <- result.then(parse_(input, 0))
  callback(varint, more)
}
