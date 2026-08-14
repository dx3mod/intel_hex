let make_raw_record_bytes ?checksum ~address ~kind ~payload () =
  let bytes = Bytes.create (5 + String.length payload) in

  let checksum =
    match checksum with
    | Some checksum -> checksum
    | None ->
        let payload_sum_bytes =
          String.fold_left (fun sum ch -> int_of_char ch + sum) 0 payload
        in

        -(payload_sum_bytes + address + String.length payload + kind) land 0xFF
  in

  Bytes.set_uint8 bytes 0 String.(length payload);
  Bytes.set_uint16_be bytes 1 address;
  Bytes.set_uint8 bytes 3 kind;
  Bytes.blit_string payload 0 bytes 4 String.(length payload);
  Bytes.set_uint8 bytes String.(length payload + 4) checksum;

  Bytes.unsafe_to_string bytes

let raw_record_bytes_of_record (record : Record.t) =
  match record with
  | Data (address, payload) ->
      make_raw_record_bytes ~kind:0x00 ~address ~payload ()
  | End_of_file ->
      make_raw_record_bytes ~kind:0x01 ~checksum:0xff ~address:0 ~payload:"" ()
  | Extended_segment_address segment_address ->
      let buf = Bytes.create 2 in
      Bytes.set_uint16_be buf 0 segment_address;
      make_raw_record_bytes ~kind:0x02 ~address:0
        ~payload:(Bytes.unsafe_to_string buf)
        ()
  | Extended_linear_address linear_address ->
      let buf = Bytes.create 2 in
      Bytes.set_uint16_be buf 0 linear_address;
      make_raw_record_bytes ~kind:0x04 ~address:0
        ~payload:(Bytes.unsafe_to_string buf)
        ()
  | Start_segment_address { cs; ip } ->
      let buf = Bytes.create 4 in
      Bytes.set_uint16_be buf 0 cs;
      Bytes.set_uint16_be buf 2 ip;
      make_raw_record_bytes ~kind:0x03 ~address:0
        ~payload:(Bytes.unsafe_to_string buf)
        ()
  | Start_linear_address linear_address ->
      let buf = Bytes.create 4 in
      Bytes.set_int32_be buf 0 (Int32.of_int linear_address);
      make_raw_record_bytes ~kind:0x05 ~address:0
        ~payload:(Bytes.unsafe_to_string buf)
        ()

let encode_hex bytes =
  let hex_map = "0123456789abcdef" in

  (* Snippet from Ohex library. *)
  let encode_into src tgt ?(off = 0) () =
    String.iteri
      (fun idx c ->
        let hi, lo =
          let i = int_of_char c in
          (*  in place uppercase *)

          Char.
            ( uppercase_ascii hex_map.[i lsr 4],
              uppercase_ascii hex_map.[i land 0x0F] )
        in

        Bytes.set tgt ((idx * 2) + off) hi;
        Bytes.set tgt ((idx * 2) + off + 1) lo)
      src
  in

  let buf = Bytes.create (String.length bytes * 2) in
  encode_into bytes buf ();
  Bytes.unsafe_to_string buf

let encode_record_to_string record =
  Printf.sprintf ":%s\n" (encode_hex @@ raw_record_bytes_of_record record)

let encode_to_string records =
  List.map
    (fun record ->
      Printf.sprintf ":%s" (encode_hex @@ raw_record_bytes_of_record record))
    records
  |> String.concat "\n"

let encode_into_channel oc records =
  List.iter
    (fun record ->
      Out_channel.output_char oc ':';

      raw_record_bytes_of_record record
      |> encode_hex
      |> Out_channel.output_string oc;

      if not (Record.is_eof record) then Out_channel.output_char oc '\n')
    records
