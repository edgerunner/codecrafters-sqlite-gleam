import file_streams/file_stream.{type FileStream}
import gleam/result

pub type DB {
  DB(
    /// The database page size in bytes. Must be a power of two between
    /// 512 and 32768 inclusive, or the value 1 representing a page size of 65536.
    page_size: Int,
    /// File format write version. 1 for legacy; 2 for WAL.
    file_format_write_version: FileFormat,
    /// File format read version. 1 for legacy; 2 for WAL.
    file_format_read_version: FileFormat,
    /// Bytes of unused "reserved" space at the end of each page. Usually 0.
    reserved_space: Int,
    /// File change counter.
    file_change_counter: Int,
    /// Size of the database file in pages. The "in-header database size".
    database_size: Int,
    /// Page number of the first freelist trunk page.
    first_trunk: Int,
    /// Total number of freelist pages.
    total_freelist_pages: Int,
    /// The schema cookie.
    schema_cookie: Int,
    /// The schema format number. Supported schema formats are 1, 2, 3, and 4.
    schema_format: SchemaFormat,
    /// Default page cache size.
    default_page_cache: Int,
    /// The page number of the largest root b-tree page when in auto-vacuum or
    /// incremental-vacuum modes, or zero otherwise.
    vacuum_mode_page_number: Int,
    /// The database text encoding.
    text_encoding: Encoding,
    /// The "user version" as read and set by the user_version pragma.
    user_version: Int,
    /// Incremental-vacuum mode.
    incremental_vacuum_mode: Bool,
    /// The "Application ID" set by PRAGMA application_id.
    application_id: Int,
    /// The version-valid-for number.
    version_valid_for: Int,
    /// SQLITE_VERSION_NUMBER
    sqlite_version: Int,
    /// File stream used to read this database
    fs: FileStream,
  )
}

pub type FileFormat {
  Legacy
  /// Write-ahead logging
  WAL
}

pub type Encoding {
  Utf8
  Utf16le
  Utf16be
}

pub type SchemaFormat {
  SchemaFormat1
  SchemaFormat2
  SchemaFormat3
  SchemaFormat4
}

/// Byte length of the header section
pub const length = 100

pub fn read(fs: FileStream) -> DB {
  let assert Ok(0) = file_stream.position(fs, file_stream.BeginningOfFile(0))
  // 0	16	The header string: "SQLite format 3\000"
  let assert Ok("SQLite format 3\u{0}") = file_stream.read_chars(fs, 16)
  // 16	2	The database page size in bytes. Must be a power of two between
  // 512 and 32768 inclusive, or the value 1 representing a page size of 65536.
  let assert Ok(page_size) = file_stream.read_uint16_be(fs)
  // 18	1	File format write version. 1 for legacy; 2 for WAL.
  let assert Ok(file_format_write_version) =
    file_stream.read_uint8(fs) |> result.map(parse_file_format)
  // 19	1	File format read version. 1 for legacy; 2 for WAL.
  let assert Ok(file_format_read_version) =
    file_stream.read_uint8(fs) |> result.map(parse_file_format)
  // 20	1	Bytes of unused "reserved" space at the end of each page. Usually 0.
  let assert Ok(reserved_space) = file_stream.read_uint8(fs)
  // 21	1	Maximum embedded payload fraction. Must be 64.
  let assert Ok(64) = file_stream.read_uint8(fs)
  // 22	1	Minimum embedded payload fraction. Must be 32.
  let assert Ok(32) = file_stream.read_uint8(fs)
  // 23	1	Leaf payload fraction. Must be 32.
  let assert Ok(32) = file_stream.read_uint8(fs)
  // 24	4	File change counter.
  let assert Ok(file_change_counter) = file_stream.read_uint32_be(fs)
  // 28	4	Size of the database file in pages. The "in-header database size".
  let assert Ok(database_size) = file_stream.read_uint32_be(fs)
  // 32	4	Page number of the first freelist trunk page.
  let assert Ok(first_trunk) = file_stream.read_uint32_be(fs)
  // 36	4	Total number of freelist pages.
  let assert Ok(total_freelist_pages) = file_stream.read_uint32_be(fs)
  // 40	4	The schema cookie.
  let assert Ok(schema_cookie) = file_stream.read_uint32_be(fs)
  // 44	4	The schema format number. Supported schema formats are 1, 2, 3, and 4.
  let assert Ok(schema_format) =
    file_stream.read_uint32_be(fs) |> result.map(parse_schema_format)
  // 48	4	Default page cache size.
  let assert Ok(default_page_cache) = file_stream.read_uint32_be(fs)
  // 52	4	The page number of the largest root b-tree page when in auto-vacuum
  // or incremental-vacuum modes, or zero otherwise.
  let assert Ok(vacuum_mode_page_number) = file_stream.read_uint32_be(fs)
  // 56	4	The database text encoding. A value of 1 means UTF-8. A value of 2
  // means UTF-16le. A value of 3 means UTF-16be.
  let assert Ok(text_encoding) =
    file_stream.read_uint32_be(fs) |> result.map(parse_text_encoding)
  // 60	4	The "user version" as read and set by the user_version pragma.
  let assert Ok(user_version) = file_stream.read_uint32_be(fs)
  // 64	4	True (non-zero) for incremental-vacuum mode. False (zero) otherwise.
  let assert Ok(incremental_vacuum_mode) =
    file_stream.read_uint32_be(fs) |> result.map(parse_incremental_vacuum_mode)
  // 68	4	The "Application ID" set by PRAGMA application_id.
  let assert Ok(application_id) = file_stream.read_uint32_be(fs)
  // 72	20	Reserved for expansion. Must be zero.
  let assert Ok(<<0:160>>) = file_stream.read_bytes(fs, 20)
  // 92	4	The version-valid-for number.
  let assert Ok(version_valid_for) = file_stream.read_uint32_be(fs)
  // 96	4	SQLITE_VERSION_NUMBER
  let assert Ok(sqlite_version) = file_stream.read_uint32_be(fs)

  DB(
    page_size:,
    file_format_write_version:,
    file_format_read_version:,
    reserved_space:,
    file_change_counter:,
    database_size:,
    first_trunk:,
    total_freelist_pages:,
    schema_cookie:,
    schema_format:,
    default_page_cache:,
    vacuum_mode_page_number:,
    text_encoding:,
    user_version:,
    incremental_vacuum_mode:,
    application_id:,
    version_valid_for:,
    sqlite_version:,
    fs:,
  )
}

fn parse_file_format(value: Int) -> FileFormat {
  case value {
    1 -> Legacy
    2 -> WAL
    _ -> panic as "Invalid file format in header"
  }
}

fn parse_schema_format(value: Int) -> SchemaFormat {
  case value {
    1 -> SchemaFormat1
    2 -> SchemaFormat2
    3 -> SchemaFormat3
    4 -> SchemaFormat4
    _ -> panic as "Invalid schema format in header"
  }
}

fn parse_text_encoding(value: Int) -> Encoding {
  case value {
    1 -> Utf8
    2 -> Utf16le
    3 -> Utf16be
    _ -> panic as "Invalid text encoding in header"
  }
}

fn parse_incremental_vacuum_mode(value: Int) -> Bool {
  case value {
    0 -> False
    _ -> True
  }
}
