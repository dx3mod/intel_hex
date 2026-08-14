module Cli = struct
  let input_file = ref ""
  and output_file = ref ""

  let speclist = [ ("-o", Arg.Set_string output_file, "Set output file name") ]
  let anon_fun filename = input_file := filename

  let parse () =
    Arg.parse speclist anon_fun "data_to_ihex <filename> [-o <output-filename>]";

    if !output_file = "" then output_file := !input_file ^ ".hex"
end

let () =
  Cli.parse ();

  let ihex_obj =
    In_channel.with_open_text !Cli.input_file @@ fun ic ->
    In_channel.input_all ic |> Intel_hex.Object.from_string
  in

  Out_channel.with_open_text !Cli.output_file @@ fun oc ->
  Intel_hex.Encode.into_channel oc ihex_obj
