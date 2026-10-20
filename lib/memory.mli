(** Memory image. *)

type t
(** The type for represents memory images. *)

(** The type for represents execution start addresses of a memory image. *)
and execution_start_address =
  | Linear_address of { eip : int }
  | Segment_address of { cs : int; ip : int }

val execution_start_address : t -> execution_start_address option
(** [execution_start_address memory] returns the actual execution start address
    of the loaded Intel HEX object. *)

module Segment : sig
  (** Memory contents block (segment). *)

  type t = int * string
  (** The type contains an address and content. *)

  val compare : t -> t -> int
  val is_empty : t -> bool
  val pp : Format.formatter -> t -> unit
end

(** {2 Fills memory} *)

exception Segment_overlap
exception Multiply_execution_start_address

val of_object : Object.t -> t
(** [of_object object] creates a [memory] image from the Intel HEX [object].

    @raise Segment_overlap
    @raise Multiply_execution_start_address *)

val of_string : ?block_size:int -> string -> t
(** [of_string ?block_size contents] chops the [contents] string into segments
    of [block_size]. *)

(** {2 Dumps memory} *)

val to_string : ?fill:int -> t -> string
(** [to_string ?fill memory] dumps the [memory] image into a binary string with
    filled gaps using the [fill] parameter (is zero by default).

    Example:
    {[
    Intel_hex.Memory.of_object [ Data (0x06, "Hello!") ]
    |> Intel_hex.Memory.to_string
    (* - : string = "\000\000\000\000\000\000Hello!" *)
    ]} *)

val output_to_buffer : ?fill:int -> t -> Buffer.t -> unit
(** [output_to_buffer ?fill memory buffer] is similar to {!to_string}, but dumps
    to the [buffer]. *)

val to_object : t -> Object.t
(** [to_object memory] dumps the [memory] image into an Intel HEX object. *)

(** {2 Processing memory segments} *)

val to_list : t -> Segment.t list
val to_seq : t -> Segment.t Seq.t
val fold : (Segment.t -> 'a -> 'a) -> t -> 'a -> 'a
val find_segment : (Segment.t -> bool) -> t -> Segment.t
val find_segment_opt : (Segment.t -> bool) -> t -> Segment.t option
val iter : (Segment.t -> unit) -> t -> unit
val get_real_memory_usage : t -> int
val get_memory_usage : t -> int
val pp : Format.formatter -> t -> unit [@@ocaml.toplevel_printer]
