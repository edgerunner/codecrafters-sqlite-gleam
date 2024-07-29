import file_streams/file_stream.{type FileStream}
import gleam/iterator
import sqlite/serial_type.{type SerialType}
import varint

pub fn read(fs: FileStream) -> List(SerialType) {
  let byte_size = varint.read(fs)
  let types_byte_size = byte_size - varint.byte_size(byte_size)
  iterator.unfold(from: types_byte_size, with: fn(remaining_size: Int) {
    case remaining_size {
      0 -> iterator.Done
      _ -> {
        let type_data = varint.read(fs)
        let type_data_size = varint.byte_size(type_data)
        let remaining_size = remaining_size - type_data_size
        let serial_type = serial_type.from_int(type_data)
        iterator.Next(element: serial_type, accumulator: remaining_size)
      }
    }
  })
  |> iterator.to_list
}
