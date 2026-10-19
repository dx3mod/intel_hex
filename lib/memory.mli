(** Segmented memory image. *)

type t
(** The type for segmented memory images. *)

module Segment : sig
  type t = int * string
  (** The type for memory segments, represented as an address-content pair. *)

  val is_empty : t -> bool
  (** [is_empty s] tests whether the segment [s] has empty contents. *)

  val compare : t -> t -> int
  (** [compare s0 s1] compares segments [s0] and [s1] by their addresses. *)

  val pp : Format.formatter -> t -> unit
  [@@ocaml.toplevel_printer]
  (** [pp ppf s] formats the segment [s] on [ppf]. *)
end

(** {2 Construction}

    Functions for creating memory images from object records or raw data. *)

val of_object : Object.t -> t
(** [of_object records] creates a memory image from the Intel HEX object
    records.

    @raise Segment_overlap if two segments overlap.
    @raise Multiply_execution_start_address
      if multiple execution start addresses are encountered. *)

val of_string : ?block_size:int -> string -> t
(** [of_string ?block_size s] creates a memory image by slicing [s] into blocks
    of [block_size] bytes (default is [16]). *)

(** {2 Serialization}

    Functions for serializing memory images into strings or buffers. *)

val to_string : ?fill:int -> t -> string
(** [to_string ?fill m] serializes the memory image [m] into a string, filling
    any address gaps with the byte [fill] (default is [0]). *)

val output_to_buffer : ?fill:int -> t -> Buffer.t -> unit
(** [output_to_buffer ?fill m buf] appends the serialized representation of the
    memory image [m] to the buffer [buf], filling any address gaps with the byte
    [fill] (default is [0]). *)

(** {2 Inspection & Metadata}

    Functions for inspecting properties, calculating usage, and retrieving
    metadata. *)

val get_real_memory_usage : t -> int
(** [get_real_memory_usage m] is the total size in bytes of all actual data
    stored in the segments of [m]. *)

val get_memory_usage : t -> int
(** [get_memory_usage m] is the upper address bound of [m] (defined as the end
    address of the highest segment, or [0] if empty). *)

val execution_start_address :
  t -> [ `Linear_address of int | `Segment_address of cs:int * ip:int ] option
(** [execution_start_address m] is the optional execution start address of [m].
*)

val pp : Format.formatter -> t -> unit
[@@ocaml.toplevel_printer]
(** [pp ppf m] formats the memory image [m] on [ppf]. *)

(** {2 Traversal & Searching}

    Functions for iterating, folding, searching, and converting memory segments.
*)

val iter : (Segment.t -> unit) -> t -> unit
(** [iter f m] applies [f] to each segment in [m]. *)

val to_list : t -> Segment.t list
(** [to_list m] is the list of segments in [m] ordered by address. *)

val to_seq : t -> Segment.t Seq.t
(** [to_seq m] is the sequence of segments in [m]. *)

val fold : (Segment.t -> 'a -> 'a) -> t -> 'a -> 'a
(** [fold f m init] folds [f] over the segments of [m] starting with [init]. *)

val find_segment : (Segment.t -> bool) -> t -> Segment.t
(** [find_segment p m] is the first segment in [m] satisfying the predicate [p].
*)

val find_segment_opt : (Segment.t -> bool) -> t -> Segment.t option
(** [find_segment_opt p m] is the first segment in [m] satisfying [p], or [None]
    if none match. *)

(** {2 Exceptions}

    Errors that can occur during memory image construction. *)

exception Segment_overlap
(** Raised when two memory segments overlap. *)

exception Multiply_execution_start_address
(** Raised when multiple execution start addresses are encountered in object
    records. *)
