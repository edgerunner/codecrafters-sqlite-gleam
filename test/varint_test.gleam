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
