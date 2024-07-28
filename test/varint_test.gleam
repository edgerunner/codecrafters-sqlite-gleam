import glacier/should
import varint

pub fn parse_0_test() {
  varint.parse(<<0:1, 0:7>>)
  |> should.be_ok
  |> should.equal(0)
}

pub fn parse_1_test() {
  varint.parse(<<0:1, 1:7>>)
  |> should.be_ok
  |> should.equal(1)
}

pub fn parse_100_test() {
  varint.parse(<<0:1, 100:7>>)
  |> should.be_ok
  |> should.equal(100)
}

pub fn parse_127_test() {
  varint.parse(<<0:1, 127:7>>)
  |> should.be_ok
  |> should.equal(127)
}

pub fn parse_128_test() {
  varint.parse(<<1:1, 1:7, 0:1, 0:7>>)
  |> should.be_ok
  |> should.equal(128)
}

pub fn parse_8256_test() {
  varint.parse(<<1:1, 64:7, 0:1, 64:7>>)
  |> should.be_ok
  |> should.equal(8256)
}

pub fn parse_16383_test() {
  varint.parse(<<1:1, 127:7, 0:1, 127:7>>)
  |> should.be_ok
  |> should.equal(16_383)
}

pub fn parse_16384_test() {
  varint.parse(<<1:1, 1:7, 1:1, 0:7, 0:1, 0:7>>)
  |> should.be_ok
  |> should.equal(16_384)
}

pub fn parse_1000000_test() {
  varint.parse(<<1:1, 61:7, 1:1, 4:7, 0:1, 64:7>>)
  |> should.be_ok
  |> should.equal(1_000_000)
}

pub fn parse_minus_1000000_test() {
  varint.parse(<<
    1:1, 0b1111111:7, 1:1, 0b1111111:7, 1:1, 0b1111111:7, 1:1, 0b1111111:7, 1:1,
    0b1111111:7, 1:1, 0b1111111:7, 1:1, 0b1100001:7, 1:1, 0b0111101:7,
    0b11000000:8,
  >>)
  |> should.be_ok
  |> should.equal(-1_000_000)
}

pub fn parse_min_test() {
  varint.parse(<<
    1:1, 0b1000000:7, 1:1, 0b0000000:7, 1:1, 0b0000000:7, 1:1, 0b0000000:7, 1:1,
    0b0000000:7, 1:1, 0b0000000:7, 1:1, 0b0000000:7, 1:1, 0b0000000:7,
    0b00000000:8,
  >>)
  |> should.be_ok
  |> should.equal(-9_223_372_036_854_775_808)
}

pub fn parse_max_test() {
  varint.parse(<<
    1:1, 0b0111111:7, 1:1, 0b1111111:7, 1:1, 0b1111111:7, 1:1, 0b1111111:7, 1:1,
    0b1111111:7, 1:1, 0b1111111:7, 1:1, 0b1111111:7, 1:1, 0b1111111:7,
    0b11111111:8,
  >>)
  |> should.be_ok
  |> should.equal(9_223_372_036_854_775_807)
}

pub fn ignore_more_data_test() {
  varint.parse(<<1:1, 64:7, 0:1, 64:7, 13_593:16>>)
  |> should.be_ok
  |> should.equal(8256)
}

pub fn chain_multiple_varints_test() {
  let data = <<
    1:1, 64:7, 0:1, 64:7, 0:1, 100:7, 1:1, 127:7, 0:1, 100:7, 13_593:16,
  >>
  use first, more <- varint.then(data)
  should.equal(first, 8256)
  use second, more <- varint.then(more)
  should.equal(second, 100)
  use third, more <- varint.then(more)
  should.equal(third, 16_356)
  should.equal(more, <<13_593:16>>) |> Ok
}

pub fn read_9_bytes_test() {
  use fs <- stream()
  varint.read(fs)
  |> should.equal(6_100_498_040_124_418_645)
}

pub fn read_8_bytes_test() {
  use fs <- stream()
  let assert Ok(1) = file_stream.position(fs, file_stream.BeginningOfFile(1))
  varint.read(fs)
  |> should.equal(23_830_070_469_236_053)
}

pub fn read_7_bytes_test() {
  use fs <- stream()
  let assert Ok(2) = file_stream.position(fs, file_stream.BeginningOfFile(2))
  varint.read(fs)
  |> should.equal(186_172_425_540_949)
}

pub fn read_6_bytes_test() {
  use fs <- stream()
  let assert Ok(3) = file_stream.position(fs, file_stream.BeginningOfFile(3))
  varint.read(fs)
  |> should.equal(1_454_472_074_581)
}

pub fn read_5_bytes_test() {
  use fs <- stream()
  let assert Ok(4) = file_stream.position(fs, file_stream.BeginningOfFile(4))
  varint.read(fs)
  |> should.equal(11_363_063_125)
}

pub fn read_4_bytes_test() {
  use fs <- stream()
  let assert Ok(5) = file_stream.position(fs, file_stream.BeginningOfFile(5))
  varint.read(fs)
  |> should.equal(88_773_973)
}

pub fn read_3_bytes_test() {
  use fs <- stream()
  let assert Ok(6) = file_stream.position(fs, file_stream.BeginningOfFile(6))
  varint.read(fs)
  |> should.equal(693_589)
}

pub fn read_2_bytes_test() {
  use fs <- stream()
  let assert Ok(7) = file_stream.position(fs, file_stream.BeginningOfFile(7))
  varint.read(fs)
  |> should.equal(5461)
}

pub fn read_1_byte_test() {
  use fs <- stream()
  let assert Ok(8) = file_stream.position(fs, file_stream.BeginningOfFile(8))
  varint.read(fs)
  |> should.equal(85)
}

import file_streams/file_open_mode
import file_streams/file_stream

const varint_file_path = "varints.raw"

pub fn stream(test_body: fn(file_stream.FileStream) -> Nil) {
  let assert Ok(fs) = file_stream.open(varint_file_path, [file_open_mode.Read])
  test_body(fs)
  let assert Ok(_) = file_stream.close(fs)
}
