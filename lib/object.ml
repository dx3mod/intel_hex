type t = Record.t list

let pp ppf records =
  Format.fprintf ppf "@[<hv 1>[%a]@]"
    (Format.pp_print_list
       ~pp_sep:(fun out () -> Format.fprintf out ";@ ")
       Record.pp)
    records

let into_blob ~write records =
  let upper_linear_base_address = ref 0 and linear_address_offset = ref 0 in

  let aux = function
    | Record.Data (address, payload) ->
        let address = (!upper_linear_base_address lsl 16) lor address in
        write address payload
    | Record.Extended_linear_address lba -> upper_linear_base_address := lba
    | Record.Start_linear_address lao -> linear_address_offset := lao
    | Record.End_of_file ->
        (* Control flow *)
        raise_notrace End_of_file
    | _ -> (* ignored *) ()
  in

  try List.iter aux records with End_of_file -> ()

let from_blob ?(address = 0) ~read () =
  let rec aux address =
    match read () with
    | None -> [ Record.End_of_file ]
    | Some payload ->
        Record.Data (address, payload) :: aux (address + String.length payload)
  in

  if address > 0xFFFF then
    Record.Extended_linear_address (address lsr 16) :: aux (address land 0xFFFF)
  else aux address

let from_string ?address ?(block_size = 16) string =
  let length = ref @@ String.length string and offset = ref 0 in

  let read () =
    if !length > 0 then (
      let payload = String.sub string !offset (min block_size !length) in

      length := !length - block_size;
      offset := !offset + block_size;

      Some payload)
    else None
  in

  from_blob ?address ~read ()
