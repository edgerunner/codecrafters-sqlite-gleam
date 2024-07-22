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

pub fn parse_1180591620717411303423_test() {
  varint.parse(<<
    1:1, 127:7, 1:1, 127:7, 1:1, 127:7, 1:1, 127:7, 1:1, 127:7, 1:1, 127:7, 1:1,
    127:7, 1:1, 127:7, 1:1, 127:7, 0:1, 127:7,
  >>)
  |> should.be_ok
  |> should.equal(1_180_591_620_717_411_303_423)
}
