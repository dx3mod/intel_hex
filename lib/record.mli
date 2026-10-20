(** Intel HEX line record. *)

(** The type is used to conveniently represent Intel HEX object records. *)
type t =
  | Data of (int * string)
      (** A memory data block contains an address and content. *)
  | End_of_file
  | Extended_segment_address of int
  | Extended_linear_address of int
  | Start_linear_address of { eip : int }
  | Start_segment_address of { cs : int; ip : int }

val of_string : string -> t
(** [of_string line] parses the record [line].

    Example:
    {[
    Intel_hex.Record.of_string ":00000001FF"
    (* - : Intel_hex.Record.t = Intel_hex.Record.End_of_file *)
    ]}

    @param line
      Correct Intel HEX record line without a newline character at the end.

    @raise Invalid_argument If parsing fails. *)

val to_string : t -> string
(** [to_string record] encodes the [record] into a new Intel HEX string.

    Example:
    {[
    Intel_hex.Record.to_string End_of_file
    (* - : string = ":00000001FF" *)
    ]} *)

val output_to_buffer : t -> Buffer.t -> unit
(** [output_to_buffer record buffer] encodes the [record] into an Intel HEX
    string to the [buffer]. *)

val is_eof : t -> bool
(** [is_eof record] checks the [record] on [End_of_file] variant. *)

val pp : Format.formatter -> t -> unit
[@@ocaml.toplevel_printer]
(** [pp ppf record] pretty print the [record] into the [ppf] formatter. *)
