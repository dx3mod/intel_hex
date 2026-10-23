open Alcotest

let test_record_from_record_string_rejects_missing_start_code () =
  check_raises "00000001FF"
    Intel_hex.Parse_error.(Error Missing_start_character)
  @@ fun () -> Intel_hex.Record.of_string "00000001FF" |> ignore

let test_record_from_record_string_rejects_non_hex_characters () =
  check_raises ":000000q1ff"
    Intel_hex.Parse_error.(Error Invalid_hexadecimal_body)
  @@ fun () -> Intel_hex.Record.of_string ":000000q1ff" |> ignore

let test_record_from_record_string_rejects_invalid_checksums () =
  check_raises ":0B0010006164647265737320676170FF"
    Intel_hex.Parse_error.(
      Error (Checksum_mismatched { expected = 0xA7; actual = 0xFF }))
    begin fun () ->
    Intel_hex.Record.of_string ":0B0010006164647265737320676170FF" |> ignore
    end;

  check_raises ":020000021200EB"
    Intel_hex.Parse_error.(
      Error (Checksum_mismatched { expected = 0xEA; actual = 0xEB }))
    begin fun () ->
    Intel_hex.Record.of_string ":020000021200EB" |> ignore
    end

let intel_hex_record = testable Intel_hex.Record.pp ( = )

let test_reader_processes_well_formed_ihex_object () =
  let ihex_text =
    ":0B0010006164647265737320676170A7\n\
     :020000021200EA\n\
     :0400000300003800C1\n\
     :02000004FFFFFC\n\
     :04000005000000CD2A\n\
     :00000001FF"
  in

  let expected =
    Intel_hex.Record.
      [
        Data (16, "address gap");
        Extended_segment_address 0x1200;
        Start_segment_address { cs = 0; ip = 0x3800 };
        Extended_linear_address 0xFFFF;
        Start_linear_address { eip = 0x000000CD };
        End_of_file;
      ]
  in

  check (list intel_hex_record) "IHEX object" expected
    (Intel_hex.Object.of_string ihex_text)

let () =
  run "Decode"
    [
      ( "Record",
        [
          test_case "Rejects missing start code" `Quick
            test_record_from_record_string_rejects_missing_start_code;
          test_case "Rejects non hex characters" `Quick
            test_record_from_record_string_rejects_non_hex_characters;
          test_case "Rejects invalid checksums" `Quick
            test_record_from_record_string_rejects_invalid_checksums;
          test_case "Reader process well formed IHEX object" `Quick
            test_reader_processes_well_formed_ihex_object;
        ] );
    ]
