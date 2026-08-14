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
