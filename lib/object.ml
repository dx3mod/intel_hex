type t = Record.t list

let pp ppf records =
  Format.fprintf ppf "@[<hv 1>[%a]@]"
    (Format.pp_print_list
       ~pp_sep:(fun out () -> Format.fprintf out ";@ ")
       Record.pp)
    records

let rec output_to_buffer records buffer =
  match records with
  | [] -> ()
  | record :: [] -> Record.output_to_buffer record buffer
  | record :: records ->
      Record.output_to_buffer record buffer;
      Buffer.add_char buffer '\n';
      output_to_buffer records buffer

let to_string records =
  let buffer = Buffer.create 0xff in
  output_to_buffer records buffer;
  Buffer.contents buffer

let of_string source =
  String.split_on_char '\n' source
  |> List.filter_map @@ fun line ->
     let line = String.trim line in
     if String.is_empty line then None else Some (Record.of_string line)

let rec of_channel ic =
  match In_channel.input_line ic with
  | None -> []
  | Some line ->
      let line = String.trim line in

      if String.is_empty line then Record.of_string line :: of_channel ic
      else of_channel ic

let to_channel records oc =
  List.iter
    begin fun record ->
      Out_channel.output_string oc (Record.to_string record);
      Out_channel.output_char oc '\n'
    end
    records
