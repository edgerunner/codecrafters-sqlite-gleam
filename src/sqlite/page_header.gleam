import file_streams/file_stream.{type FileStream}
import gleam/function
import gleam/result

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
  let curry4_rewind_5th = fn(fun) {
    fn(a) {
      fn(b) {
        fn(c) {
          fn(d) {
            fn(_) {
              let assert Ok(_) =
                file_stream.position(fs, file_stream.CurrentLocation(-4))
              fun(a, b, c, d)
            }
          }
        }
      }
    }
  }
  // 0	1	The one-byte flag at offset 0 indicating the b-tree page type.
  let page_header = case file_stream.read_uint8(fs) {
    // A value of 2 (0x02) means the page is an interior index b-tree page.
    Ok(0x02) -> function.curry5(InteriorIndex)
    // A value of 5 (0x05) means the page is an interior table b-tree page.
    Ok(0x05) -> function.curry5(InteriorTable)
    // A value of 10 (0x0a) means the page is a leaf index b-tree page.
    Ok(0x0a) -> curry4_rewind_5th(LeafIndex)
    // A value of 13 (0x0d) means the page is a leaf table b-tree page.
    Ok(0x0d) -> curry4_rewind_5th(LeafTable)
    // Any other value for the b-tree page type is an error.
    Ok(_) -> panic as "Invalid page type"
    Error(_) -> panic as "FileStream error"
  }
  // 1	2	The two-byte integer at offset 1 gives the start of the first freeblock on the page,
  // or is zero if there are no freeblocks.
  let assert Ok(page_header) =
    file_stream.read_uint16_be(fs) |> result.map(page_header)
  // 3	2	The two-byte integer at offset 3 gives the number of cells on the page.
  let assert Ok(page_header) =
    file_stream.read_uint16_be(fs) |> result.map(page_header)
  // 5	2	The two-byte integer at offset 5 designates the start of the cell
  // content area. A zero value for this integer is interpreted as 65536.
  let assert Ok(page_header) =
    file_stream.read_uint16_be(fs)
    |> result.map(fn(cca) {
      case cca {
        0 -> 65_536
        _ -> cca
      }
    })
    |> result.map(page_header)
  // 7	1	The one-byte integer at offset 7 gives the number of fragmented
  // free bytes within the cell content area.
  let assert Ok(page_header) =
    file_stream.read_uint8(fs) |> result.map(page_header)
  // 8	4	The four-byte page number at offset 8 is the right-most pointer.
  // This value appears in the header of interior b-tree pages only and is
  // omitted from all other pages.
  let assert Ok(page_header) =
    file_stream.read_uint8(fs) |> result.map(page_header)

  page_header
}
