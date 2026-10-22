(** Intel HEX object. *)

type t = Record.t list
(** The type for represents a list of Intel HEX records. *)

val of_string : string -> t
(** [of_string object] parses the Intel HEX [object] string source.

    See also {!Record.of_string}.

    @param object Correct Intel HEX object string.

    @raise Invalid_argument If parsing fails. *)

val to_string : t -> string
(** [to_string object] encodes the Intel HEX [object] into a new Intel HEX
    object string. *)

val to_buffer : Buffer.t -> t -> unit
(** [to_buffer buffer object] encodes the Intel HEX [object] into an Intel HEX
    object string to the [buffer]. *)

val of_channel : in_channel -> t
(** [of_channel ic] is similar to {!of_string}, but for input channels. *)

val to_channel : t -> out_channel -> unit
(** [to_channel oc] is similar to {!to_string}, but for output channels. *)

val pp : Format.formatter -> t -> unit
[@@ocaml.toplevel_printer]
(** [pp ppf record] pretty print the Intel HEX [object] into the [ppf]
    formatter. *)
