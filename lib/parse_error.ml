type t =
  | Missing_start_character
  | Checksum_mismatched of { expected : int; actual : int }
  | Too_small_source
  | Invalid_hexadecimal_body

exception Error of t
