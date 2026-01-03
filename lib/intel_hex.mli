(** The Intel HEX manipulating library for OCaml provides functions for reading,
    writing, and creating. *)

type t = Record.t list
(** A Intel HEX file is composed of many records. *)

(** {1 Create}

    You can use the high-level interface (via the {!Record.t} module) to
    construct Intel HEX files. Here is an example:

    {[
      let ihex =
        Intel_hex.Record.
          [
            Data { offset = 0; payload = "hello " };
            Data { offset = 7; payload = "world" };
            (* ... *)
          ]
    ]} *)

(** {1 Read} *)

val of_channel : in_channel -> t
(** [of_channel ic] read Intel HEX record from input channel. *)

val of_string : string -> t
(** [of_string s] read Intel HEX record from [s] string. *)

(** {1 Write} *)

val to_string : t -> string
(** [to_string ihex] returns string representation of Intel HEX. *)

val output_to_buffer : Buffer.t -> t -> unit
(** [output_to_buffer buf ihex] output string representation of Intel HEX to
    [buf] buffer. *)

(** {1 Raw access} *)

(** Raw Intel HEX structure manipulation. *)
module Raw : sig
  type t = Record.Raw.t list

  val of_channel : in_channel -> t
  val of_string : string -> t
  val output_to_buffer : Buffer.t -> t -> unit
  val to_string : t -> string
end

(** {1 Modules} *)

module Record = Record
