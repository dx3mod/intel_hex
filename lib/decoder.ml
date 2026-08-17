type error =
  | Missing_start_code
  | Checksum_mismatched of (int * int)
  | Illegal_record_type of int

exception Error of error

let raise_error err = raise (Error err)

let decode_record_line_exn line =
  if line.[0] <> ':' then raise_error Missing_start_code;

  let bytes =
    Ohex.decode
    @@
    (* NOTE: performance issue! *)
    String.sub line 1 String.(length line - 1)
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
    raise_error @@ Checksum_mismatched (checksum, expected_checksum);

  (* Make Record.t from raw values *)
  match kind with
  | 0x00 -> Record.Data (address, payload)
  | 0x01 -> Record.End_of_file
  | 0x02 -> Record.Extended_segment_address String.(get_uint16_be payload 0)
  | 0x04 -> Record.Extended_linear_address String.(get_uint16_be payload 0)
  | 0x05 ->
      Record.Start_linear_address
        String.(get_int32_be payload 0 |> Int32.to_int)
  | 0x03 ->
      Record.Start_segment_address
        {
          cs = String.get_int16_be payload 0;
          ip = String.get_int16_be payload 2;
        }
  | _ -> raise_error @@ Illegal_record_type kind

let decode_object_from_string_exn string =
  String.split_on_char '\n' string |> List.map decode_record_line_exn

let[@tail_mod_cons] rec decode_object_from_channel_exn ic =
  match input_line ic |> decode_record_line_exn with
  | exception End_of_file -> []
  | Record.End_of_file as record -> [ record ]
  | record -> record :: decode_object_from_channel_exn ic
