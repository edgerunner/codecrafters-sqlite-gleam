import file_streams/file_stream.{type FileStream}
import gleam/list
import sqlite/db_header

pub type PageHeader {
  LeafTable(
    freeblock: Int,
    cells: Int,
    pointers: List(Int),
    content: Int,
    fragmented: Int,
  )
  LeafIndex(
    freeblock: Int,
    cells: Int,
    pointers: List(Int),
    content: Int,
    fragmented: Int,
  )
  InteriorTable(
    freeblock: Int,
    cells: Int,
    pointers: List(Int),
    content: Int,
    fragmented: Int,
    right: Int,
  )
  InteriorIndex(
    freeblock: Int,
    cells: Int,
    pointers: List(Int),
    content: Int,
    fragmented: Int,
    right: Int,
  )
}

pub fn read(fs: FileStream) -> PageHeader {
  // 0	1	The one-byte flag at offset 0 indicating the b-tree page type.
  case file_stream.read_uint8(fs) {
    // A value of 2 (0x02) means the page is an interior index b-tree page.
    Ok(0x02) -> interior(InteriorIndex, fs)
    // A value of 5 (0x05) means the page is an interior table b-tree page.
    Ok(0x05) -> interior(InteriorTable, fs)
    // A value of 10 (0x0a) means the page is a leaf index b-tree page.
    Ok(0x0a) -> leaf(LeafIndex, fs)
    // A value of 13 (0x0d) means the page is a leaf table b-tree page.
    Ok(0x0d) -> leaf(LeafTable, fs)
    // Any other value for the b-tree page type is an error.
    Ok(_) -> panic as "Invalid page type"
    Error(_) -> panic as "FileStream error"
  }
}

fn read8(fs: FileStream) -> Int {
  let assert Ok(int8) = file_stream.read_uint8(fs)
  int8
}

fn read16(fs: FileStream) -> Int {
  let assert Ok(int16) = file_stream.read_uint16_be(fs)
  int16
}

fn read32(fs: FileStream) -> Int {
  let assert Ok(int32) = file_stream.read_uint32_be(fs)
  int32
}

fn leaf(
  variant: fn(Int, Int, List(Int), Int, Int) -> PageHeader,
  fs: FileStream,
) {
  // 1	2	The two-byte integer at offset 1 gives the start of the first freeblock on the page,
  // or is zero if there are no freeblocks.
  let freeblock = read16(fs)
  // 3	2	The two-byte integer at offset 3 gives the number of cells on the page.
  let cells = read16(fs)
  // 5	2	The two-byte integer at offset 5 designates the start of the cell
  // content area. A zero value for this integer is interpreted as 65536.
  let content = read16(fs)
  // 7	1	The one-byte integer at offset 7 gives the number of fragmented
  // free bytes within the cell content area.
  let fragments = read8(fs)

  // 8 2* The cell pointer index is an array of two-byte integers.
  let pointers =
    list.repeat(fs, cells)
    |> list.map(read16)

  variant(freeblock, cells, pointers, content, fragments)
}

fn interior(
  variant: fn(Int, Int, List(Int), Int, Int, Int) -> PageHeader,
  fs: FileStream,
) {
  // 1	2	The two-byte integer at offset 1 gives the start of the first freeblock on the page,
  // or is zero if there are no freeblocks.
  let freeblock = read16(fs)
  // 3	2	The two-byte integer at offset 3 gives the number of cells on the page.
  let cells = read16(fs)
  // 5	2	The two-byte integer at offset 5 designates the start of the cell
  // content area. A zero value for this integer is interpreted as 65536.
  let content = read16(fs)
  // 7	1	The one-byte integer at offset 7 gives the number of fragmented
  // free bytes within the cell content area.
  let fragments = read8(fs)
  // 8	4	The four-byte page number at offset 8 is the right-most pointer.
  // This value appears in the header of interior b-tree pages only and is
  // omitted from all other pages.
  let right = read32(fs)

  // 8 2* The cell pointer index is an array of two-byte integers.
  let pointers =
    list.repeat(fs, cells)
    |> list.map(read16)

  variant(freeblock, cells, pointers, content, fragments, right)
}

pub fn offset(page_number p: Int, page_size s: Int) {
  case p {
    invalid if invalid < 1 -> panic as "Invalid page number"
    1 -> db_header.length
    p -> p * s - s
  }
}
