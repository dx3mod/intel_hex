open Alcotest

let test_record_to_string_for_data_record () =
  let empty_data_record = Intel_hex.Record.Data (0, "") in

  check string "Empty data record" ":0000000000\n"
    (Intel_hex.Record.to_string empty_data_record);

  let data = Intel_hex.Record.Data (0x0010, "address gap") in

  check string "Data 'address gap'" ":0B0010006164647265737320676170A7\n"
    (Intel_hex.Record.to_string data)

let test_record_to_string_for_eof_record () =
  check string "End_of_file" ":00000001FF\n"
    Intel_hex.Record.(to_string End_of_file)

let () =
  run "Encode"
    [
      ( "Record.to_string",
        [
          test_case "Data" `Quick test_record_to_string_for_data_record;
          test_case "Eof" `Quick test_record_to_string_for_eof_record;
        ] );
    ]
