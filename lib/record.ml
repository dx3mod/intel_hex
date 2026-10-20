type t =
  | Data of (int * string)
  | End_of_file
  | Extended_segment_address of int
  | Extended_linear_address of int
  | Start_linear_address of int
  | Start_segment_address of { cs : int; ip : int }

let is_eof = function End_of_file -> true | _ -> false

let pp fmt = function
  | Data (address, payload) ->
      Format.fprintf fmt "Intel_hex.Record.Data(0x%04X, %S)" address payload
  | End_of_file -> Format.pp_print_string fmt "Intel_hex.Record.End_of_file"
  | Extended_segment_address addr ->
      Format.fprintf fmt "Intel_hex.Record.Extended_segment_address(0x%04X)"
        addr
  | Extended_linear_address addr ->
      Format.fprintf fmt "Intel_hex.Record.Extended_linear_address(0x%04X)" addr
  | Start_linear_address addr ->
      Format.fprintf fmt "Intel_hex.Record.Start_linear_address(0x%04X)" addr
  | Start_segment_address { cs; ip } ->
      Format.fprintf fmt
        "Intel_hex.Record.Start_segment_address(cs: %d, ip: %d)" cs ip

module Raw = struct
  type t = { kind : int; address : int; payload : string; checksum : int }

  let make ~kind ~address ?checksum payload =
    let checksum =
      match checksum with
      | Some checksum -> checksum
      | None ->
          let payload_sum_bytes =
            String.fold_left (fun sum ch -> int_of_char ch + sum) 0 payload
          in

          -(payload_sum_bytes + address + String.length payload + kind)
          land 0xFF
    in

    { kind; address; payload; checksum }

  let output_to_buffer { kind; address; payload; checksum } buffer =
    let bytes = Bytes.create (5 + String.length payload) in

    Bytes.set_uint8 bytes 0 String.(length payload);
    Bytes.set_uint16_be bytes 1 address;
    Bytes.set_uint8 bytes 3 kind;
    Bytes.blit_string payload 0 bytes 4 String.(length payload);
    Bytes.set_uint8 bytes String.(length payload + 4) checksum;

    Buffer.add_char buffer ':';
    Hexen.encode_to_buffer ~uppercase:true (Bytes.unsafe_to_string bytes) buffer;
    Buffer.add_char buffer '\n'

  let of_string line =
    if line.[0] <> ':' then invalid_arg "intel_hex: missing record's start code";

    let bytes =
      try Hexen.decode_substring line 1 (String.length line - 1)
      with Invalid_argument _ ->
        invalid_arg "intel_hex: invalid hexadecimal record's body"
    in

    (* Get fields from cstruct buffer *)
    let length = String.get_uint8 bytes 0 in
    let address = String.get_uint16_be bytes 1 in
    let kind = String.get_uint8 bytes 3 in
    let payload = String.sub bytes 4 length in

    (* Verify checksum *)
    let checksum = String.get_uint8 bytes (4 + length)
    and expected_checksum =
      let payload_sum_bytes =
        String.fold_left (fun sum ch -> int_of_char ch + sum) 0 payload
      in

      -(payload_sum_bytes + address + String.length payload + kind) land 0xFF
    in

    if checksum <> expected_checksum then
      invalid_arg
      @@ Printf.sprintf
           "intel_hex: record's checksum mismatched: expected 0x%X but got 0x%X"
           expected_checksum checksum;

    { kind; address; payload; checksum }
end

let to_raw record =
  match record with
  | Data (address, payload) -> Raw.make ~kind:0x00 ~address payload
  | End_of_file -> Raw.make ~kind:0x01 ~checksum:0xff ~address:0 ""
  | Extended_segment_address segment_address ->
      let buf = Bytes.create 2 in
      Bytes.set_uint16_be buf 0 segment_address;

      Raw.make ~kind:0x02 ~address:0 (Bytes.unsafe_to_string buf)
  | Extended_linear_address linear_address ->
      let buf = Bytes.create 2 in
      Bytes.set_uint16_be buf 0 linear_address;

      Raw.make ~kind:0x04 ~address:0 (Bytes.unsafe_to_string buf)
  | Start_segment_address { cs; ip } ->
      let buf = Bytes.create 4 in
      Bytes.set_uint16_be buf 0 cs;
      Bytes.set_uint16_be buf 2 ip;

      Raw.make ~kind:0x03 ~address:0 (Bytes.unsafe_to_string buf)
  | Start_linear_address linear_address ->
      let buf = Bytes.create 4 in
      Bytes.set_int32_be buf 0 (Int32.of_int linear_address);

      Raw.make ~kind:0x05 ~address:0 (Bytes.unsafe_to_string buf)

let output_to_buffer record buffer = Raw.output_to_buffer (to_raw record) buffer

let to_string record =
  let buffer = Buffer.create 0xff in
  output_to_buffer record buffer;
  Buffer.contents buffer

let of_string line =
  let Raw.{ kind; address; payload; _ } = Raw.of_string line in

  match kind with
  | 0x00 -> Data (address, payload)
  | 0x01 -> End_of_file
  | 0x02 -> Extended_segment_address String.(get_uint16_be payload 0)
  | 0x04 -> Extended_linear_address String.(get_uint16_be payload 0)
  | 0x05 -> Start_linear_address String.(get_int32_be payload 0 |> Int32.to_int)
  | 0x03 ->
      Start_segment_address
        {
          cs = String.get_int16_be payload 0;
          ip = String.get_int16_be payload 2;
        }
  | _ -> invalid_arg "intel_hex: illegal record type"
