type t = int * string

let length (_, data) = String.length data

let pp fmt (addr, data) =
  Format.fprintf fmt "0x%04x, " addr;

  if String.is_valid_utf_8 data then Format.fprintf fmt "\"%s\"" data
  else
    Format.pp_print_string fmt (Cstruct.to_hex_string (Cstruct.of_string data))
