module Record = Record

module Raw = struct
  type t = Record.Raw.t list

  let rec of_channel ic =
    match In_channel.input_line ic with
    | Some "" | None -> []
    | Some line -> Record.Raw.of_string line :: of_channel ic

  let of_string s =
    String.split_on_char '\n' s
    |> List.filter_map (function
      | "" -> None
      | line -> Record.Raw.of_string line |> Option.some)

  let output_to_buffer buf t = List.iter (Record.Raw.output_to_buffer buf) t

  let to_string t =
    let buf = Buffer.create 1024 in
    output_to_buffer buf t;
    Buffer.contents buf
end

type t = Record.t list

let of_channel ic = Raw.of_channel ic |> List.map Record.of_raw
and of_string s = Raw.of_string s |> List.map Record.of_raw

let output_to_buffer buf t =
  List.map Record.to_raw t |> Raw.output_to_buffer buf

let to_string t =
  let buf = Buffer.create 1024 in
  output_to_buffer buf t;
  Buffer.contents buf
