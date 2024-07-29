import file_streams/file_stream.{type FileStream}
import gleam/iterator
import gleam/list
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

pub fn read(fs: FileStream) -> Int {
  iterator.repeat(fs)
  |> iterator.take(9)
  |> iterator.fold_until(from: <<>>, with: fn(bytes, fs) {
    case file_stream.read_bytes(fs, 1) {
      Ok(<<1:1, _:7>> as byte) -> list.Continue(<<bytes:bits, byte:bits>>)
      Ok(<<0:1, _:7>> as byte) -> list.Stop(<<bytes:bits, byte:bits>>)
      _ -> panic as "Could not read varint"
    }
  })
  |> parse_or_panic
}

fn parse_or_panic(bits: BitArray) -> Int {
  let assert Ok(result) = parse(bits)
  result
}

pub fn byte_size(int: Int) -> Int {
  case int {
    neg if neg < 0x00 -> 9
    v7 if v7 < 0x80 -> 1
    v14 if v14 < 0x4000 -> 2
    v21 if v21 < 0x200000 -> 3
    v28 if v28 < 0x10000000 -> 4
    v35 if v35 < 0x800000000 -> 5
    v42 if v42 < 0x40000000000 -> 6
    v49 if v49 < 0x2000000000000 -> 7
    v56 if v56 < 0x100000000000000 -> 8
    _v64 -> 9
  }
}
