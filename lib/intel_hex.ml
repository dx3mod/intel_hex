module Object = Object
module Record = Record

module Decode = struct
  include Decoder

  let from_string s = decode_object_from_string_exn s
  and record_from_string line = decode_record_line_exn line

  let from_channel ic = decode_object_from_channel_exn ic
end

module Encode = struct
  include Encoder

  let into_string ihex_obj = encode_to_string ihex_obj
  and record_into_string record = encode_record_to_string record

  let into_channel oc ihex_obj = encode_into_channel oc ihex_obj
end
