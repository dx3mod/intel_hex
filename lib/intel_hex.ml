module Record = Record
module Object = Object

let records_to_string records =
  let buf = Buffer.create 4024 in
  List.iter (fun r -> Record.to_string r |> Buffer.add_string buf) records;
  Buffer.contents buf

let records_to_channel records oc =
  List.iter
    (fun r -> Record.to_string r |> Out_channel.output_string oc)
    records

let records_of_string s =
  String.split_on_char '\n' s
  |> List.filter_map (function
    | "" -> None
    | line -> Record.of_string line |> Option.some)

let rec records_of_channel ic =
  match In_channel.input_line ic with
  | Some "" | None -> []
  | Some line -> Record.of_string line :: records_of_channel ic

let object_of_string s = records_of_string s |> Object.of_records
and object_of_channel ic = records_of_channel ic |> Object.of_records
