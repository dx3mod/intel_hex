open Alcotest

let test_record_from_record_string_rejects_missing_start_code () =
  check_raises "00000001FF" Intel_hex.Record.Missing_start_code (fun () ->
      Intel_hex.Record.of_string "00000001FF" |> ignore)

let test_record_from_record_string_rejects_non_hex_characters () =
  check_raises ":000000q1ff"
    (Invalid_argument "of_hex: invalid character at pos 6: 'q'") (fun () ->
      Intel_hex.Record.of_string ":000000q1ff" |> ignore)

let test_record_from_record_string_rejects_invalid_checksums () =
  check_raises ":0B0010006164647265737320676170FF"
    Intel_hex.Record.(Checksum_mismatched (0xA7, 0xFF))
    (fun () ->
      Intel_hex.Record.of_string ":0B0010006164647265737320676170FF" |> ignore);

  check_raises ":020000021200EB"
    Intel_hex.Record.(Checksum_mismatched (0xEA, 0xEB))
    (fun () -> Intel_hex.Record.of_string ":020000021200EB" |> ignore)

let intel_hex_record = testable Intel_hex.Record.pp ( = )

let test_reader_processes_well_formed_ihex_object () =
  let ihex_text =
    {|
      :0B0010006164647265737320676170A7
      :020000021200EA
      :0400000300003800C1
      :02000004FFFFFC
      :04000005000000CD2A
      :00000001FF
    |}
  in

  let expected =
    Intel_hex.Record.
      [
        Data (16, "address gap");
        Extended_segment_address 0x1200;
        Start_segment_address { cs = 0; ip = 0x3800 };
        Extended_linear_address 0xFFFF;
        Start_linear_address 0x000000CD;
        End_of_file;
      ]
  in

  check (list intel_hex_record) "IHEX object" expected
    (Intel_hex.records_of_string ihex_text)

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
