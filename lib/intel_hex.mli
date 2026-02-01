(** Module for manipulating Intel HEX records and objects. *)

module Record = Record
module Object = Object

(** {2 Encoding} *)

val records_to_string : Record.t list -> string
val records_to_channel : Record.t list -> out_channel -> unit

(** {2 Decoding} *)

(** {4 From string} *)

val records_of_string : string -> Record.t list
val object_of_string : string -> Object.t

(** {4 From channel} *)

val records_of_channel : in_channel -> Record.t list
val object_of_channel : in_channel -> Object.t
