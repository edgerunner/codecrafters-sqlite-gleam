import file_streams/file_stream.{type FileStream}

pub type PageHeader {
  LeafTable(freeblock: Int, cells: Int, content: Int, fragmented: Int)
  LeafIndex(freeblock: Int, cells: Int, content: Int, fragmented: Int)
  InteriorTable(
    freeblock: Int,
    cells: Int,
    content: Int,
    fragmented: Int,
    right: Int,
  )
  InteriorIndex(
    freeblock: Int,
    cells: Int,
    content: Int,
    fragmented: Int,
    right: Int,
  )
}

pub fn read(fs: FileStream) -> PageHeader {
  // 0	1	The one-byte flag at offset 0 indicating the b-tree page type.
  case file_stream.read_uint8(fs) {
    // A value of 2 (0x02) means the page is an interior index b-tree page.
    Ok(0x02) -> lazy_map5(InteriorIndex)
    // A value of 5 (0x05) means the page is an interior table b-tree page.
    Ok(0x05) -> lazy_map5(InteriorTable)
    // A value of 10 (0x0a) means the page is a leaf index b-tree page.
    Ok(0x0a) -> lazy_map4(LeafIndex)
    // A value of 13 (0x0d) means the page is a leaf table b-tree page.
    Ok(0x0d) -> lazy_map4(LeafTable)
    // Any other value for the b-tree page type is an error.
    Ok(_) -> panic as "Invalid page type"
    Error(_) -> panic as "FileStream error"
  }(
    // 1	2	The two-byte integer at offset 1 gives the start of the first freeblock on the page,
    // or is zero if there are no freeblocks.
    read16(fs),
    // 3	2	The two-byte integer at offset 3 gives the number of cells on the page.
    read16(fs),
    // 5	2	The two-byte integer at offset 5 designates the start of the cell
    // content area. A zero value for this integer is interpreted as 65536.
    read16(fs),
    // 7	1	The one-byte integer at offset 7 gives the number of fragmented
    // free bytes within the cell content area.
    read8(fs),
    // 8	4	The four-byte page number at offset 8 is the right-most pointer.
    // This value appears in the header of interior b-tree pages only and is
    // omitted from all other pages.
    read32(fs),
  )
}

fn read8(fs: FileStream) -> fn() -> Int {
  fn() {
    let assert Ok(int8) = file_stream.read_uint8(fs)
    int8
  }
}

fn read16(fs: FileStream) -> fn() -> Int {
  fn() {
    let assert Ok(int16) = file_stream.read_uint16_be(fs)
    int16
  }
}

fn read32(fs: FileStream) -> fn() -> Int {
  fn() {
    let assert Ok(int32) = file_stream.read_uint32_be(fs)
    int32
  }
}

fn lazy_map4(variant4: fn(a, b, c, d) -> r) {
  fn(fa: fn() -> a, fb: fn() -> b, fc: fn() -> c, fd: fn() -> d, _fx: fn() -> x) {
    variant4(fa(), fb(), fc(), fd())
  }
}

fn lazy_map5(variant5: fn(a, b, c, d, e) -> r) {
  fn(fa: fn() -> a, fb: fn() -> b, fc: fn() -> c, fd: fn() -> d, fe: fn() -> e) {
    variant5(fa(), fb(), fc(), fd(), fe())
  }
}
