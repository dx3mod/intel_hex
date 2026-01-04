type t = {
  kind : kind;
  length : int;
  address : int;
  checksum : int;
  payload : string;
}

and kind =
  | Data
  | End_of_file
  | Extended_segment_address
  | Extended_linear_address
  | Start_linear_address
  | Start_segment_address

(** {1 Constructors} *)

val make : kind:kind -> address:int -> string -> t
(** [make ~kind ~address payload] create a raw record type that automatically
    calculates a checksum. *)

val of_cstruct : Cstruct.t -> t
(** [of_cstruct cstruct] decode a raw record type from [cstruct] value. *)

val of_string : string -> t
(** [of_cstruct string] decode a raw record type from [string] value. *)

(** {1 Convert} *)

val to_cstruct : t -> Cstruct.t
(** [to_cstruct raw_record] returns binary representation of [raw_record]. *)

(** {2 Hexadecimal representation} *)

val to_string : t -> string
(** [to_cstruct raw_record] returns HEX representation of [raw_record]. *)

val output_to_buffer : Buffer.t -> t -> unit
(** [output_to_buffer buf raw_record] output HEX representation of [raw_record]
    to [buf] buffer. *)

(** {1 Internals} *)

val kind_of_int : int -> kind
val int_of_kind : kind -> int

(** {2 Checksum} *)

val calculate_checksum : t -> int
(** [calculate_checksum raw_record] returns CRC byte. *)

val verify : t -> bool
(** [verify raw_record] check checksum. *)
