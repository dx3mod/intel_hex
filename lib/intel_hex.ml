module Record = struct
  type t = {
    kind : kind;
    length : int;
    address : int;
    checksum : int;
    payload : string;
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

  let rec make ~kind ~address payload =
    let record =
      { kind; length = String.length payload; address; checksum = 0; payload }
    in

    { record with checksum = calculate_checksum record }

  and calculate_checksum t =
    let sum_bytes =
      String.fold_left (Fun.flip @@ Fun.compose ( + ) int_of_char) 0
    in

    (sum_bytes t.payload + t.address + t.length + int_of_kind t.kind)
    lxor 0xFF land 0xFF

  let of_cstruct cstruct =
    let length = Cstruct.get_byte cstruct 0 in
    let address = Cstruct.BE.get_uint16 cstruct 1 in
    let kind = Cstruct.get_byte cstruct 3 |> kind_of_int in
    let payload = Cstruct.to_string ~off:4 ~len:length cstruct in
    let checksum = Cstruct.get_byte cstruct (4 + length) in

    { kind; address; length; payload; checksum }

  let of_string line =
    assert (String.starts_with ~prefix:":" line);
    Cstruct.of_hex ~off:1 line |> of_cstruct

  let to_cstruct t =
    let payload_length = String.length t.payload in

    let cstruct = Cstruct.create (5 + payload_length) in

    Cstruct.set_uint8 cstruct 0 t.length;
    Cstruct.BE.set_uint16 cstruct 1 t.address;
    Cstruct.set_uint8 cstruct 3 (int_of_kind t.kind);
    Cstruct.blit_from_string t.payload 0 cstruct 4 payload_length;
    Cstruct.set_uint8 cstruct (4 + payload_length) t.checksum;

    cstruct

  let verify t = t.checksum = calculate_checksum t

  let pf fmt t =
    Format.pp_print_char fmt ':';
    Format.pp_print_string fmt @@ Cstruct.to_hex_string @@ to_cstruct t;
    Format.pp_print_flush fmt ()

  let to_string t =
    let buffer = Buffer.create 32 in
    let fmt = Format.formatter_of_buffer buffer in
    pf fmt t;
    Buffer.contents buffer
end

type t = record list
and record = Record.t

let rec of_channel ic =
  match In_channel.input_line ic with
  | None -> []
  | Some line -> Record.of_string line :: of_channel ic

let of_string s = String.split_on_char '\n' s |> List.map Record.of_string
