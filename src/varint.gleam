import gleam/io
import gleam/pair
import gleam/result

pub fn parse(input: BitArray) -> Result(Int, Nil) {
  parse_(input) |> result.map(pair.first)
}

fn parse_(input: BitArray) -> Result(#(Int, BitArray), Nil) {
  case input {
    <<0:1, s0:unsigned-7, more:bits>> -> Ok(#(s0, more))
    <<1:1, s1:unsigned-7, 0:1, s0:unsigned-7, more:bits>> ->
      Ok(#(int(<<0:50, s1:7, s0:7>>), more))

    <<1:1, s2:unsigned-7, 1:1, s1:unsigned-7, 0:1, s0:unsigned-7, more:bits>> ->
      Ok(#(int(<<0:43, s2:7, s1:7, s0:7>>), more))
    <<
      1:1,
      s3:unsigned-7,
      1:1,
      s2:unsigned-7,
      1:1,
      s1:unsigned-7,
      0:1,
      s0:unsigned-7,
      more:bits,
    >> -> Ok(#(int(<<0:36, s3:7, s2:7, s1:7, s0:7>>), more))
    <<
      1:1,
      s4:unsigned-7,
      1:1,
      s3:unsigned-7,
      1:1,
      s2:unsigned-7,
      1:1,
      s1:unsigned-7,
      0:1,
      s0:unsigned-7,
      more:bits,
    >> -> Ok(#(int(<<0:29, s4:7, s3:7, s2:7, s1:7, s0:7>>), more))
    <<
      1:1,
      s5:unsigned-7,
      1:1,
      s4:unsigned-7,
      1:1,
      s3:unsigned-7,
      1:1,
      s2:unsigned-7,
      1:1,
      s1:unsigned-7,
      0:1,
      s0:unsigned-7,
      more:bits,
    >> -> Ok(#(int(<<0:22, s5:7, s4:7, s3:7, s2:7, s1:7, s0:7>>), more))

    <<
      1:1,
      s6:unsigned-7,
      1:1,
      s5:unsigned-7,
      1:1,
      s4:unsigned-7,
      1:1,
      s3:unsigned-7,
      1:1,
      s2:unsigned-7,
      1:1,
      s1:unsigned-7,
      0:1,
      s0:unsigned-7,
      more:bits,
    >> -> Ok(#(int(<<0:15, s6:7, s5:7, s4:7, s3:7, s2:7, s1:7, s0:7>>), more))
    <<
      1:1,
      s7:unsigned-7,
      1:1,
      s6:unsigned-7,
      1:1,
      s5:unsigned-7,
      1:1,
      s4:unsigned-7,
      1:1,
      s3:unsigned-7,
      1:1,
      s2:unsigned-7,
      1:1,
      s1:unsigned-7,
      0:1,
      s0:unsigned-7,
      more:bits,
    >> ->
      Ok(#(int(<<0:8, s7:7, s6:7, s5:7, s4:7, s3:7, s2:7, s1:7, s0:7>>), more))
    <<
      1:1,
      s8:unsigned-7,
      1:1,
      s7:unsigned-7,
      1:1,
      s6:unsigned-7,
      1:1,
      s5:unsigned-7,
      1:1,
      s4:unsigned-7,
      1:1,
      s3:unsigned-7,
      1:1,
      s2:unsigned-7,
      1:1,
      s1:unsigned-7,
      s0:unsigned-8,
      more:bits,
    >> ->
      Ok(#(int(<<s8:7, s7:7, s6:7, s5:7, s4:7, s3:7, s2:7, s1:7, s0:8>>), more))

    _ -> Error(Nil)
  }
}

pub fn then(
  input: BitArray,
  callback: fn(Int, BitArray) -> Result(a, Nil),
) -> Result(a, Nil) {
  use #(varint, more) <- result.then(parse_(input))
  callback(varint, more)
}

fn int(combined: BitArray) -> Int {
  let assert <<out:signed-big-64>> = combined
  out
}
