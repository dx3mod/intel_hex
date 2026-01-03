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

  let kind_of_int = function
    | 0 -> Data
    | 1 -> End_of_file
    | 2 -> Extended_segment_address
    | 4 -> Extended_linear_address
    | 5 -> Start_linear_address
    | _ -> raise (Invalid_argument "unknown Intel HEX record type")

  and string_of_kind = function
    | Data -> "00"
    | End_of_file -> "01"
    | Extended_segment_address -> "02"
    | Extended_linear_address -> "04"
    | Start_linear_address -> "05"

  let of_cstruct cstruct =
    let length = Cstruct.get_byte cstruct 0 in
    let address = Cstruct.BE.get_uint16 cstruct 1 in
    let kind = Cstruct.get_byte cstruct 3 |> kind_of_int in
    let payload = Cstruct.to_bytes ~off:4 ~len:length cstruct in
    let checksum = Cstruct.get_byte cstruct (4 + length) in

    { kind; address; length; payload; checksum }

  let of_string line =
    assert (String.starts_with ~prefix:":" line);
    Cstruct.of_hex ~off:1 line |> of_cstruct
end
