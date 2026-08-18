(** A library for parsing and generating Intel HEX (also known as IHEX) objects.
    This format is commonly used to represent compiled program code and data
    that is loaded into a microcontroller, flash memory, or ROM in embedded
    systems programming.

    {b Example}

    {[
    utop # Intel_hex.Object.from_string ~block_size:5 "Hello World!"
           |> Intel_hex.Encode.to_string
           |> print_endline;;
    ]}
    {[
    :0500000048656C6C6F07
    :0500050020576F726C32
    :02000A0064216F
    :00000001FF
    ]}

    {[
    utop # Intel_hex.Decode.from_string ihex_text;;
    ]}
    {[
    - : Intel_hex.Object.t =
    [Intel_hex.Record.Data(0x0000, "Hello");
     Intel_hex.Record.Data(0x0005, " Worl");
     Intel_hex.Record.Data(0x000A, "d!");
     Intel_hex.Record.End_of_file]
    ]} *)

module Object = Object
module Record = Record

(** {2 Decode and encode Intel HEX objects} *)

module Decode : sig
  (** Intel HEX decoder module. *)

  (** {1 Decoding errors} *)

  (** Decoding errors type. *)
  type error =
    | Missing_start_code
    | Checksum_mismatched of (int * int)
        (** Actual checksum and expected checksum *)
    | Illegal_record_type of int

  exception Error of error
  (** Decoding errors exception. *)

  (** {3 Decode from strings} *)

  val from_string : string -> Object.t
  (** [from_string string] decode Intel HEX object from [string].

      @raise Error if decoding fails *)

  val record_from_string : string -> Record.t
  (** [record_from_string line] decode Intel HEX record from string [line].

      @raise Error if decoding fails *)

  (** {3 Decode from channels} *)

  val from_channel : in_channel -> Object.t
  (** [from_channel ic] decode Intel HEX object from [in_channel].

      @raise Error if decoding fails *)
end

module Encode : sig
  (** Intel HEX encoder module. *)

  (** {3 Encode from strings} *)

  val into_string : Object.t -> string
  (** [into_string obj] encode Intel HEX object into [string] value. *)

  val record_into_string : Record.t -> string
  (** [record_into_string record] encode Intel HEX record into line [string]
      value. *)

  (** {3 Encode into channels} *)

  val into_channel : out_channel -> Object.t -> unit
  (** [into_channel ic] encode Intel HEX object into [out_channel] stream. *)
end
