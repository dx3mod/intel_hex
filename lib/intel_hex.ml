module Record = struct
  type t = {
    kind : kind;
    length : int;
    address : int;
    checksum : int;
    payload : bytes;
  }

  and kind =
    | Data
    | End_of_file
    | Extended_segment_address
    | Extended_linear_address
    | Start_linear_address

  let kind_of_string = function
    | "00" -> Data
    | "01" -> End_of_file
    | "02" -> Extended_segment_address
    | "04" -> Extended_linear_address
    | "05" -> Start_linear_address
    | _ -> raise (Invalid_argument "unknown Intel HEX record type")

  and string_of_kind = function
    | Data -> "00"
    | End_of_file -> "01"
    | Extended_segment_address -> "02"
    | Extended_linear_address -> "04"
    | Start_linear_address -> "05"
end
