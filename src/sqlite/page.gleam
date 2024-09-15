import file_streams/file_stream.{type FileStream}
import gleam/list
import sqlite/db

pub type Page {
  Page(
    page_type: PageType,
    freeblock: Int,
    cells: Int,
    pointers: List(Int),
    content: Int,
    fragments: Int,
    node_type: NodeType,
  )
}

pub type PageType {
  Table
  Index
}

pub type NodeType {
  Leaf
  Interior(right_pointer: Int)
}

pub fn read(from db: db.DB, page page_number: Int) -> Page {
  // extract useful parts from the database header
  let db.DB(fs:, page_size:, ..) = db
  // make an offset function for this page
  let offset = make_offset(page_number:, page_size:)
  // move the file stream head to the page header
  let assert Ok(_) =
    header_offset(page_number:, page_size:)
    |> file_stream.BeginningOfFile
    |> file_stream.position(fs, _)

  // 0	1	The one-byte flag at offset 0 indicating the b-tree page type.
  let #(page_type, right_pointer_by_node_type) = case
    file_stream.read_uint8(fs)
  {
    // A value of 2 (0x02) means the page is an interior index b-tree page.
    Ok(0x02) -> #(Index, interior(fs, _))
    // A value of 5 (0x05) means the page is an interior table b-tree page.
    Ok(0x05) -> #(Table, interior(fs, _))
    // A value of 10 (0x0a) means the page is a leaf index b-tree page.
    Ok(0x0a) -> #(Index, leaf)
    // A value of 13 (0x0d) means the page is a leaf table b-tree page.
    Ok(0x0d) -> #(Table, leaf)
    // Any other value for the b-tree page type is an error.
    Ok(_) -> panic as "Invalid page type"
    Error(_) -> panic as "FileStream error"
  }

  // 1	2	The two-byte integer at offset 1 gives the start of the first freeblock on the page,
  // or is zero if there are no freeblocks.
  let freeblock = read16(fs) |> offset
  // 3	2	The two-byte integer at offset 3 gives the number of cells on the page.
  let cells = read16(fs)
  // 5	2	The two-byte integer at offset 5 designates the start of the cell
  // content area. A zero value for this integer is interpreted as 65536.
  let content = read16(fs) |> offset
  // 7	1	The one-byte integer at offset 7 gives the number of fragmented
  // free bytes within the cell content area.
  let fragments = read8(fs)

  // interior pages have a right pointer. Leaf pages don't
  let node_type = right_pointer_by_node_type(Nil)

  // 8 2* The cell pointer index is an array of two-byte integers.
  let pointers =
    list.repeat(fs, cells)
    |> list.map(read16)
    |> list.map(offset)

  Page(
    page_type:,
    freeblock:,
    cells:,
    pointers:,
    content:,
    fragments:,
    node_type:,
  )
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

fn leaf(_: Nil) -> NodeType {
  Leaf
}

fn interior(fs: FileStream, _: Nil) -> NodeType {
  // 8	4	The four-byte page number at offset 8 is the right-most pointer.
  // This value appears in the header of interior b-tree pages only and is
  // omitted from all other pages.
  let right_pointer = read32(fs)
  Interior(right_pointer:)
}

/// This function calculates the offset for reading a
/// page header. It accounts for the 100-byte database
/// header in the first page.
fn header_offset(page_number p: Int, page_size s: Int) {
  case p {
    invalid if invalid < 1 -> panic as "Invalid page number"
    1 -> db.length
    p -> p * s - s
  }
}

/// This function makes an offset function for a given page
/// The function turns the page-relative offset in the file
/// into an absolute (file-start-relative) offset
fn make_offset(page_number p: Int, page_size s: Int) {
  case p {
    invalid if invalid < 1 -> panic as "Invalid page number"
    p -> fn(o) { p * s - s + o }
  }
}
