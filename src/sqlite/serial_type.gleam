pub type SerialType {
  Null
  Int8
  Int16
  Int24
  Int32
  Int48
  Int64
  Float64
  Zero
  One
  Blob(length: Int)
  Text(length: Int)
}

pub fn from_int(value: Int) -> SerialType {
  let mod = value % 2
  case value {
    0 -> Null

    1 -> Int8
    2 -> Int16
    3 -> Int24
    4 -> Int32
    5 -> Int48
    6 -> Int64
    7 -> Float64

    8 -> Zero
    9 -> One

    b if mod == 0 && b > 11 -> Blob({ b - 12 } / 2)
    t if mod == 1 && t > 11 -> Text({ t - 13 } / 2)

    _ -> panic as "invalid serial type"
  }
}

pub fn bytes(st: SerialType) -> Int {
  case st {
    Null | Zero | One -> 0
    Int8 -> 1
    Int16 -> 2
    Int24 -> 3
    Int32 -> 4
    Int48 -> 6
    Int64 | Float64 -> 8
    Blob(length) | Text(length) -> length
  }
}

pub fn bits(st: SerialType) -> Int {
  bytes(st) * 8
}
