import file_streams/file_open_mode
import file_streams/file_stream

const database_file_path = "sample.db"

pub fn stream(test_body: fn(file_stream.FileStream) -> Nil) {
  let assert Ok(fs) =
    file_stream.open(database_file_path, [file_open_mode.Read])
  test_body(fs)
  let assert Ok(_) = file_stream.close(fs)
}
