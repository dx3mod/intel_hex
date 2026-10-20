module Segment = struct
  type t = int * string

  let pp ppf (address, contents) =
    Format.fprintf ppf "Intel_hex.Memory.Segment(0x%04X, %S)" address contents

  let compare (a, _) (a', _) = compare a a'
  let is_empty (_, contents) = contents = ""
end

module Segments = Set.Make (Segment)

type t = {
  execution_start_address :
    [ `Linear_address of int | `Segment_address of cs:int * ip:int ] option;
  segments : Segments.t;
}

let make ?execution_start_address ?(segments = Segments.empty) () =
  { execution_start_address; segments }

let execution_start_address { execution_start_address; _ } =
  execution_start_address

exception Segment_overlap
exception Multiply_execution_start_address

let is_segment_overlapped segments (address, contents) =
  (* assert (contents <> "") *)
  Segments.find_first_opt
    (fun (address', contents') -> address' + String.length contents' > address)
    segments
  |> Option.map (fun (address', _) ->
      address' < address + String.length contents)
  |> Option.value ~default:false

let add_segment' segments segment =
  assert (not @@ Segment.is_empty segment);

  if is_segment_overlapped segments segment then raise Segment_overlap
  else Segments.add segment segments

let of_object records =
  let rec loop segments extended_address start_address = function
    | Record.Data (address, contents) :: records ->
        let address =
          match extended_address with
          | None -> address
          | Some (`Linear_address la) -> (la lsl 16) lor address
          | Some (`Segment_address sa) -> (sa lsl 4) + address
        in

        loop
          (add_segment' segments (address, contents))
          extended_address start_address records
    | Record.(Start_linear_address _ | Start_segment_address _) :: _
      when Option.is_some start_address ->
        raise Multiply_execution_start_address
    | Record.Start_linear_address address :: records ->
        loop segments extended_address (Some (`Linear_address address)) records
    | Record.Start_segment_address { cs; ip } :: records ->
        loop segments extended_address
          (Some (`Segment_address (~cs, ~ip)))
          records
    | Record.Extended_linear_address address :: records ->
        loop segments (Some (`Linear_address address)) start_address records
    | Record.Extended_segment_address address :: records ->
        loop segments (Some (`Segment_address address)) start_address records
    | Record.End_of_file :: _ | [] ->
        { execution_start_address = start_address; segments }
  in

  loop Segments.empty None None records

let to_object memory =
  let records = Dynarray.create () in
  let extended_address = ref 0 in

  begin match memory.execution_start_address with
  | None -> ()
  | Some (`Linear_address address) ->
      Dynarray.add_last records (Record.Start_linear_address address)
  | Some (`Segment_address (~cs, ~ip)) ->
      Dynarray.add_last records (Record.Start_segment_address { cs; ip })
  end;

  Segments.iter
    begin fun (address, contents) ->
      let address =
        if address > 0xFFFF then (
          let extended_address' = address lsr 16 in

          if !extended_address <> extended_address' then begin
            extended_address := extended_address';
            Dynarray.add_last records
              Record.(Extended_linear_address extended_address')
          end;

          address land 0xFFFF)
        else address
      in

      Dynarray.add_last records Record.(Data (address, contents))
    end
    memory.segments;

  Dynarray.to_list records

let of_string ?(block_size = 16) source =
  let rec slicing segments remaining_source_length source_offset source =
    if remaining_source_length > 0 then
      let contents =
        String.sub source source_offset (min block_size remaining_source_length)
      in

      slicing
        (add_segment' segments (source_offset, contents))
        (remaining_source_length - block_size)
        (source_offset + block_size)
        source
    else segments
  in

  let segments = slicing Segments.empty (String.length source) 0 source in
  make ~segments ()

let output_to_buffer ?(fill = 0) memory buffer =
  let fill_buffer n ch buffer =
    for _ = 1 to n do
      Buffer.add_char buffer ch
    done
  in

  let _ =
    Segments.fold
      begin fun (address, contents) offset ->
        if address > offset then
          fill_buffer (address - offset) (char_of_int fill) buffer;

        Buffer.add_string buffer contents;
        address + String.length contents
      end
      memory.segments 0
  in

  ()

let to_string ?fill memory =
  let buffer = Buffer.create 0xFFF in
  output_to_buffer ?fill memory buffer;
  Buffer.contents buffer

let to_list memory = Segments.to_list memory.segments
let to_seq memory = Segments.to_seq memory.segments
let fold f memory acc = Segments.fold f memory.segments acc
let find_segment p memory = Segments.find_first p memory.segments
let find_segment_opt p memory = Segments.find_first_opt p memory.segments
let iter f { segments; _ } = Segments.iter f segments

let get_real_memory_usage memory =
  fold (fun (_, contents) size -> String.length contents + size) memory 0

let get_memory_usage memory =
  Segments.max_elt_opt memory.segments
  |> Option.map (fun (address, contents) -> address + String.length contents)
  |> Option.value ~default:0

let pp ppf memory =
  Format.fprintf ppf "@[<hv 1>[%a]@]"
    (Format.pp_print_list
       ~pp_sep:(fun out () -> Format.fprintf out ";@ ")
       Segment.pp)
    (to_list memory)
