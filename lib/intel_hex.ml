module Record = struct
  type t = {
    kind : kind;
    length : int;
    address : int;
    checksum : int;
    payload : [ `Hex of string | `Text of string ];
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

  and int_of_kind = function
    | Data -> 0
    | End_of_file -> 1
    | Extended_segment_address -> 2
    | Extended_linear_address -> 4
    | Start_linear_address -> 5

  let make ~kind ~address (`Hex payload) =
    let length = String.length payload in
    let checksum =
      let sum_bytes =
        String.fold_left (Fun.flip @@ Fun.compose ( + ) int_of_char) 0
      in

      (sum_bytes payload + address + length + int_of_kind kind) land 0xFF
    in

    { kind; length; address; checksum; payload = `Hex payload }

  let of_cstruct cstruct =
    let length = Cstruct.get_byte cstruct 0 in
    let address = Cstruct.BE.get_uint16 cstruct 1 in
    let kind = Cstruct.get_byte cstruct 3 |> kind_of_int in
    let payload = Cstruct.to_string ~off:4 ~len:length cstruct in
    let checksum = Cstruct.get_byte cstruct (4 + length) in

    { kind; address; length; payload = `Text payload; checksum }

  let of_string line =
    assert (String.starts_with ~prefix:":" line);
    Cstruct.of_hex ~off:1 line |> of_cstruct
end
