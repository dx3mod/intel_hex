module Raw = Raw_record

type t =
  | Data of { offset : int; payload : string }
  | End_of_file
  | Extended_segment_address of int
  | Extended_linear_address of int
  | Start_linear_address of int32
  | Start_segment_address of { cs : int; ip : int }

let to_raw_kind = function
  | Data _ -> Raw.Data
  | End_of_file -> Raw.End_of_file
  | Extended_segment_address _ -> Raw.Extended_segment_address
  | Extended_linear_address _ -> Raw.Extended_linear_address
  | Start_linear_address _ -> Raw.Start_linear_address
  | Start_segment_address _ -> Raw.Start_segment_address

let pp fmt = function
  | Data { offset; payload } ->
      Format.fprintf fmt "Intel_hex.Record.Data(0x%04x, \"" offset;
      Format.pp_print_string fmt payload;
      Format.pp_print_string fmt "\")"
  | End_of_file -> Format.pp_print_string fmt "Intel_hex.Record.End_of_file"
  | Extended_segment_address addr ->
      Format.fprintf fmt "Intel_hex.Record.Extended_segment_address(%d)" addr
  | Extended_linear_address addr ->
      Format.fprintf fmt "Intel_hex.Record.Extended_linear_address(%d)" addr
  | Start_linear_address addr ->
      Format.fprintf fmt "Intel_hex.Record.Start_linear_address(%ld)" addr
  | Start_segment_address { cs; ip } ->
      Format.fprintf fmt
        "Intel_hex.Record.Start_segment_address(cs: %d, ip: %d)" cs ip

let to_string t =
  let buf = Buffer.create 32 in
  let fmt = Format.formatter_of_buffer buf in
  pp fmt t;
  Format.pp_print_flush fmt ();
  Buffer.contents buf

let of_raw raw_record =
  match raw_record.Raw.kind with
  | Raw.Data ->
      Data { offset = raw_record.address; payload = raw_record.payload }
  | Raw.End_of_file -> End_of_file
  | Raw.Extended_segment_address ->
      Extended_segment_address (String.get_uint16_be raw_record.payload 0)
  | Raw.Extended_linear_address ->
      Extended_linear_address (String.get_uint16_be raw_record.payload 0)
  | Raw.Start_linear_address ->
      Start_linear_address (String.get_int32_be raw_record.payload 0)
  | Raw.Start_segment_address ->
      let cs = String.get_int16_be raw_record.payload 0 in
      let ip = String.get_int16_be raw_record.payload 2 in

      Start_segment_address { cs; ip }

let to_raw = function
  | Data { offset; payload } -> Raw.make ~kind:Data ~address:offset payload
  | End_of_file -> Raw.make ~kind:End_of_file ~address:0x0000 ""
  | Extended_segment_address segment_address ->
      let buf = Bytes.create 2 in
      Bytes.set_uint16_be buf 0 segment_address;

      Raw.make ~kind:Extended_segment_address ~address:0x0000
      @@ Bytes.unsafe_to_string buf
  | Extended_linear_address segment_address ->
      let buf = Bytes.create 2 in
      Bytes.set_uint16_be buf 0 segment_address;

      Raw.make ~kind:Extended_linear_address ~address:0x0000
      @@ Bytes.unsafe_to_string buf
  | Start_segment_address { cs; ip } ->
      let buf = Bytes.create 4 in
      Bytes.set_uint16_be buf 0 cs;
      Bytes.set_uint16_be buf 0 ip;

      Raw.make ~kind:Start_segment_address ~address:0x0000
      @@ Bytes.unsafe_to_string buf
  | Start_linear_address address ->
      let buf = Bytes.create 4 in
      Bytes.set_int32_be buf 0 address;

      Raw.make ~kind:Start_linear_address ~address:0x0000
      @@ Bytes.unsafe_to_string buf
