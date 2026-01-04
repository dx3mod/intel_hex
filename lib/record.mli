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

val to_raw : t -> Raw.t
(** [to_raw record] returns a raw record representation of [record]. *)

val of_raw : Raw.t -> t
(** [of_raw raw_record] transform [raw_record] to user friendly record type. *)

(** {2 Kind} *)

val to_raw_kind : t -> Raw.kind

(** {1 Pretty print} *)

val pp : Format.formatter -> t -> unit
(** [pp fmt record] pretty print to formatter the [record] value. *)

val to_string : t -> string
(** [to_string record] returns pretty print string of [record] value. *)
