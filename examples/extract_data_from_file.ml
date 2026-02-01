let () =
  if Array.length Sys.argv != 2 then begin
    prerr_endline "Usage: extract_data [FILENAME]";
    prerr_endline "Saves data from [FILENAME] to [FILENAME].data";
    exit 1
  end;

  let filename = Sys.argv.(1) in

  let intel_hex_object =
    In_channel.with_open_text filename Intel_hex.object_of_channel
    |> Intel_hex.Object.normalize
  in

  Out_channel.with_open_text (filename ^ ".data") begin fun oc ->
      List.iter
        (Fun.compose (Out_channel.output_string oc) snd)
        intel_hex_object.chunks
    end
