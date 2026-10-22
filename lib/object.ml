type t = Record.t list

let pp ppf records =
  Format.fprintf ppf "@[<hv 1>[%a]@]"
    (Format.pp_print_list
       ~pp_sep:(fun out () -> Format.fprintf out ";@ ")
       Record.pp)
    records

let rec to_buffer buffer records =
  match records with
  | [] -> ()
  | record :: [] -> Record.to_buffer buffer record
  | record :: records ->
      Record.to_buffer buffer record;
      Buffer.add_char buffer '\n';
      to_buffer buffer records

let to_string records =
  let buffer = Buffer.create 0xff in
  to_buffer buffer records;
  Buffer.contents buffer

let of_string source =
  String.split_on_char '\n' source
  |> List.filter_map @@ fun line ->
     match String.trim line with
     | "" -> None
     | line -> Some (Record.of_string line)

let rec of_channel ic =
  match In_channel.input_line ic with
  | None -> []
  | Some line ->
      begin match String.trim line with
      | "" -> of_channel ic
      | line -> Record.of_string line :: of_channel ic
      end

let to_channel records oc =
  List.iter
    begin fun record ->
      Out_channel.output_string oc (Record.to_string record);
      Out_channel.output_char oc '\n'
    end
    records
