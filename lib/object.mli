(** Module for representing IHEX objects for payload (data) manipulation. *)

type t = {
  start_linear_address : int;
  start_segment_address : start_segment_address;
  chunks : Chunk.t list;
}

and start_segment_address = { cs : int; ip : int }

val make : Chunk.t list -> t
val of_records : Record.t list -> t
