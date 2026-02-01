let eval code =
  let as_buf = Lexing.from_string code in
  let parsed = !Toploop.parse_toplevel_phrase as_buf in
  ignore (Toploop.execute_phrase true Format.std_formatter parsed)

let () =
  eval {|#require "intel_hex";;|};
  eval "#install_printer Intel_hex.Chunk.pp;;";
  eval "#install_printer Intel_hex.Record.pp;;"
