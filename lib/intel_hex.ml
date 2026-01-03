module Record = Record

module Raw = struct
  type t = Record.Raw.t list

  let rec of_channel ic =
    match In_channel.input_line ic with
    | Some "" | None -> []
    | Some line -> Record.Raw.of_string line :: of_channel ic

  let of_string s = String.split_on_char '\n' s |> List.map Record.Raw.of_string

  let pf fmt t =
    List.iter
      (fun r ->
        Record.Raw.pf fmt r;
        Format.pp_print_newline fmt ())
      t

  let to_string t =
    let buf = Buffer.create 1024 in
    let fmt = Format.formatter_of_buffer buf in
    pf fmt t;
    Buffer.contents buf
end
