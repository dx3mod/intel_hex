(** The module contains Intel HEX object type and function to process it. *)

type t = Record.t list
(** Intel HEX object type. *)

val pp : Format.formatter -> t -> unit
[@@ocaml.toplevel_printer]
(** [pp ppf ihex_object] pretty print Intel HEX object into [format] object. *)

(** {2 From/into to linear blob memory} *)

val into_blob : write:(int -> string -> unit) -> t -> unit
(** [into_blob ~write ihex_object]

    Map {!Record.Data} records into some blob object. Supports only linear
    address!

    {b Example}

    {[
    let write address payload =
      Out_channel.seek oc Int64.(of_int address);
      Out_channel.output_string oc payload
    in
    Intel_hex.Object.into_blob ~write ihex_object
    ]} *)

val from_blob : ?address:int -> read:(unit -> string option) -> unit -> t
(** [from_blob ?address ~read ()]

    Map some linear addresses to an Intel HEX object.

    @param address is linear base address, by default is 0. *)

(** {3 From strings} *)

val from_string : ?address:int -> ?block_size:int -> string -> t
(** [of_string ?address ~block_size string]

    Map the [string] into linear addresses Intel HEX object.

    @param address is linear base address, by default is 0.
    @param block_size
      is number of {!Record.Data} payload's length, by default is 16. *)
