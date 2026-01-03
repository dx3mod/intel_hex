(** Intel HEX record representation. *)

module Raw = Raw_record

(** User friendly Intel HEX record representation. *)
type t =
  | Data of { offset : int; payload : string }
  | End_of_file
  | Extended_segment_address of int
  | Extended_linear_address of int
  | Start_linear_address of int32
  | Start_segment_address of { cs : int; ip : int }

(** {1 Convert} *)

val to_raw_kind : t -> Raw.kind
val to_raw : t -> Raw.t
val of_raw : Raw.t -> t

(** {1 Pretty print} *)

val pp : Format.formatter -> t -> unit
val to_string : t -> string
