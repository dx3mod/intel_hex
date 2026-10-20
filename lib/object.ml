type t = Record.t list

let pp ppf records =
  Format.fprintf ppf "@[<hv 1>[%a]@]"
    (Format.pp_print_list
       ~pp_sep:(fun out () -> Format.fprintf out ";@ ")
       Record.pp)
    records

let output_to_buffer records buffer =
  List.iter (fun record -> Record.output_to_buffer record buffer) records

let to_string records =
  let buffer = Buffer.create 0xff in
  output_to_buffer records buffer;
  Buffer.contents buffer
