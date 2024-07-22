pub fn parse(input: BitArray) -> Result(Int, Nil) {
  parse_(input, 0)
}

fn parse_(input: BitArray, big: Int) -> Result(Int, Nil) {
  case input {
    <<0:1, little:unsigned-7>> -> Ok(big + little)
    <<1:1, middle:unsigned-7, more:bits>> ->
      parse_(more, { big + middle } * 128)
    _ -> Error(Nil)
  }
}
