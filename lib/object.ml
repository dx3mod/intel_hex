type t = {
  start_linear_address : int;
  start_segment_address : start_segment_address;
  chunks : Chunk.t list;
}

and start_segment_address = { cs : int; ip : int }

let make chunks =
  {
    start_linear_address = 0;
    start_segment_address = { cs = 0; ip = 0 };
    chunks;
  }

let of_records records =
  let extended_linear_address = ref 0 and extended_segment_address = ref 0 in
  let start_linear_address = ref 0
  and start_segment_address = ref { cs = 0; ip = 0 } in

  let addr_space = ref `Linear in
  let eof = ref false in

  let chunks =
    List.filter_map
      (function
        | _ when !eof -> None
        | Record.Data (addr, data) when !addr_space = `Linear ->
            let addr = (!extended_linear_address lsl 16) lor addr in
            Some (addr, data)
        | Record.Data (addr, data) when !addr_space = `Segment ->
            let addr = (!extended_segment_address lsl 4) lor addr in
            Some (addr, data)
        | Extended_linear_address linear_addr ->
            extended_linear_address := linear_addr;
            None
        | Extended_segment_address seg_addr ->
            extended_segment_address := seg_addr;
            addr_space := `Segment;
            None
        | Start_linear_address linear_addr ->
            start_linear_address := linear_addr;
            None
        | Start_segment_address { cs; ip } ->
            start_segment_address := { cs; ip };
            None
        | End_of_file ->
            eof := true;
            None
        | _ -> None)
      records
  in

  {
    chunks;
    start_linear_address = !start_linear_address;
    start_segment_address = !start_segment_address;
  }
