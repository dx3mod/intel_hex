(** Intel HEX record's module.

    The module contains Intel HEX record type and function to process it. *)

(** Intel HEX record type. *)
type t =
  | Data of (int * string)  (** Address and payload *)
  | End_of_file
  | Extended_segment_address of int
  | Extended_linear_address of int
  | Start_linear_address of int
  | Start_segment_address of { cs : int; ip : int }

val is_eof : t -> bool
(** [is_eof record] returns [true] if [record] is [End_of_file] variant else
    returns [false]. *)

val pp : Format.formatter -> t -> unit
[@@ocaml.toplevel_printer]
(** [pp ppf record] pretty print the [record] value into [ppf] format object. *)
