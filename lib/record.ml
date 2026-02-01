type t =
  | Data of Chunk.t
  | End_of_file
  | Extended_segment_address of int
  | Extended_linear_address of int
  | Start_linear_address of int
  | Start_segment_address of { cs : int; ip : int }

let pp fmt = function
  | Data chunk -> Format.fprintf fmt "Intel_hex.Record.Data(%a)" Chunk.pp chunk
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

exception Missing_start_code
exception Checksum_mismatched of int * int
exception Unsupported_record_type of int

let () =
  Printexc.register_printer @@ function
  | Missing_start_code -> Some "Missing_start_code(':')"
  | Checksum_mismatched (checksum, expected_checksum) ->
      Some
        Printf.(
          sprintf "Checksum_mismatched(0x%02X, expecting 0x%02X)" checksum
            expected_checksum)
  | Unsupported_record_type kind ->
      Some Printf.(sprintf "Unsupported_record_type(%02x)" kind)
  | _ -> None

let calculate_checksum ~addr ~kind ~payload =
  let payload_sum_bytes =
    String.fold_left (fun sum ch -> int_of_char ch + sum) 0 payload
  in

  -(payload_sum_bytes + addr + String.length payload + kind) land 0xFF

let make_raw_record ?(addr = 0) ~kind payload =
  let payload_length = String.length payload in
  let cstruct = Cstruct.create (5 + payload_length) in

  Cstruct.set_uint8 cstruct 0 payload_length;
  Cstruct.BE.set_uint16 cstruct 1 addr;
  Cstruct.set_uint8 cstruct 3 kind;
  Cstruct.blit_from_string payload 0 cstruct 4 payload_length;
  Cstruct.set_uint8 cstruct (4 + payload_length)
    (calculate_checksum ~addr ~kind ~payload);

  cstruct

let to_cstruct = function
  | Data (addr, data) -> make_raw_record ~addr ~kind:0 data
  | End_of_file -> make_raw_record ~kind:1 String.empty
  | Extended_segment_address seg_addr ->
      let buf = Bytes.create 2 in
      Bytes.set_uint16_be buf 0 seg_addr;
      make_raw_record ~kind:2 (Bytes.unsafe_to_string buf)
  | Extended_linear_address linear_addr ->
      let buf = Bytes.create 2 in
      Bytes.set_uint16_be buf 0 linear_addr;
      make_raw_record ~kind:4 (Bytes.unsafe_to_string buf)
  | Start_segment_address { cs; ip } ->
      let buf = Bytes.create 4 in
      Bytes.set_uint16_be buf 0 cs;
      Bytes.set_uint16_be buf 2 ip;
      make_raw_record ~kind:3 (Bytes.unsafe_to_string buf)
  | Start_linear_address linear_addr ->
      let buf = Bytes.create 4 in
      Bytes.set_int32_be buf 0 (Int32.of_int linear_addr);
      make_raw_record ~kind:5 (Bytes.unsafe_to_string buf)

let of_cstruct cstruct =
  (* Get fields from cstruct buffer *)
  let length = Cstruct.get_uint8 cstruct 0 in
  let address = Cstruct.BE.get_uint16 cstruct 1 in
  let kind = Cstruct.get_uint8 cstruct 3 in
  let payload = Cstruct.to_string ~off:4 ~len:length cstruct in

  (* Verify checksum *)
  let checksum = Cstruct.get_uint8 cstruct (4 + length) in
  let expected_checksum = calculate_checksum ~addr:address ~kind ~payload in

  if checksum <> expected_checksum then
    raise @@ Checksum_mismatched (expected_checksum, checksum);

  (* Make Record.t from raw values *)
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
  | _ -> raise @@ Unsupported_record_type kind

let of_cstruct_opt cstruct =
  try of_cstruct cstruct |> Option.some with _ -> None

let of_string line =
  if line.[0] <> ':' then raise Missing_start_code;

  Cstruct.of_hex ~off:1 line |> of_cstruct

let to_string t =
  (* Uppercase to HEX string version of Cstruct.to_hex_string function for performance.  *)
  let output_uppercase_hex_string_to_buffer buf t =
    let open Cstruct in
    let[@inline] nibble_to_char (i : int) : char =
      if i < 10 then Char.chr (i + Char.code '0')
      else Char.chr (i - 10 + Char.code 'A')
    in

    for i = 0 to length t - 1 do
      let ch = Char.code @@ Bigarray.Array1.get t.buffer (i + t.off) in

      Buffer.add_char buf (nibble_to_char (ch lsr 4));
      Buffer.add_char buf (nibble_to_char (ch land 0xf))
    done
  in

  let cstruct = to_cstruct t in
  let buf = Buffer.create (3 + Cstruct.length cstruct) in

  Buffer.add_char buf ':';
  output_uppercase_hex_string_to_buffer buf cstruct;
  Buffer.add_char buf '\n';

  Buffer.contents buf
