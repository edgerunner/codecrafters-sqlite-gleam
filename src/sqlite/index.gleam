import gleam/list
import gleam/order
import sqlite/cell
import sqlite/db.{type DB}
import sqlite/page
import sqlite/schema.{type Index}
import sqlite/value.{type Value}

pub fn search(in db: DB, on index: Index, for value: Value) -> List(Int) {
  search_page(db:, page: index.root_page, for: value, from: NoneFound)
  |> to_list
}

type Found {
  NoneFound
  SomeFound(List(Int))
  AllFound(List(Int))
}

fn found(results: Found, id: Int) -> Found {
  case results {
    NoneFound -> SomeFound([id])
    SomeFound(so_far) -> SomeFound([id, ..so_far])
    AllFound(_) -> results
  }
}

fn all_found(results: Found) -> Found {
  case results {
    NoneFound -> AllFound([])
    SomeFound(so_far) -> AllFound(so_far)
    AllFound(_) -> results
  }
}

fn to_list(results: Found) -> List(Int) {
  case results {
    NoneFound -> []
    SomeFound(so_far) | AllFound(so_far) -> so_far
  }
}

fn search_page(
  db db: DB,
  page page_number: Int,
  for value: Value,
  from results: Found,
) -> Found {
  let page = page.read(from: db, page: page_number)
  let cells = cell.read_all(from: db, in: page_number)
  case page.node_type {
    page.Leaf -> {
      use results, cell <- list.fold(over: cells, from: results)
      let assert cell.IndexLeafCell(record: [key, value.Integer(id)], ..) = cell

      case value.compare(key, value) {
        order.Lt -> results
        order.Eq -> found(results, id)
        order.Gt -> all_found(results)
      }
    }
    page.Interior(right_pointer:) ->
      {
        use results, cell <- list.fold(over: cells, from: results)
        let assert cell.IndexInteriorCell(
          left_child_pointer:,
          record: [key, value.Integer(id)],
          ..,
        ) = cell
        case value.compare(key, value), results {
          // this line ensures we do not keep searching
          // additional pages if we already found some and
          // gone past the matching key
          _, AllFound(_) -> results
          order.Lt, _ -> results
          order.Eq, _ ->
            search_page(
              db:,
              page: left_child_pointer,
              for: value,
              from: found(results, id),
            )
          order.Gt, _ ->
            search_page(
              db:,
              page: left_child_pointer,
              for: value,
              from: results,
            )
        }
      }
      |> fn(results) {
        case results {
          NoneFound | SomeFound(_) ->
            search_page(db:, page: right_pointer, for: value, from: results)
          AllFound(_) -> results
        }
      }
  }
}
