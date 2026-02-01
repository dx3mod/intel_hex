(** Line record of IHEX object. *)

type t =
  | Data of Chunk.t
  | End_of_file
  | Extended_segment_address of int
  | Extended_linear_address of int
  | Start_linear_address of int
  | Start_segment_address of { cs : int; ip : int }

val pp : Format.formatter -> t -> unit
(** [pp fmt record] *)

(** {2 Decode} *)

val to_cstruct : t -> Cstruct.t
val to_string : t -> string

(** {2 Encode} *)

val of_cstruct : Cstruct.t -> t
(** [of_cstruct cstruct] decode a record from cstruct buffer.

    @raise Checksum_mismatched
    @raise Unsupported_record_type *)

val of_cstruct_opt : Cstruct.t -> t option

val of_string : string -> t
(** [of_string s] decode a record from string source.

    @raise Invalid_argument if [s] is invalid
    @raise Missing_start_code
    @raise Checksum_mismatched
    @raise Unsupported_record_type *)

(** {2 Exceptions} *)

exception Missing_start_code

exception Checksum_mismatched of int * int
(** [(checksum, expected_checksum)] *)

exception Unsupported_record_type of int
