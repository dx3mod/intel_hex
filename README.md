# intel_hex

The Intel HEX manipulation library for OCaml provides functions to read, write, and create Intel HEX format data, which is commonly used in embedded systems programming.

[API references](https://ocaml.org/p/intel_hex/latest/doc/index.html)

## Usage

If you are using Dune, add the `intel_hex` library to your libraries stanza.

Here is an example that creates an IHEX object file with test data and then prints it:

```ocaml
let ihex =
  Intel_hex.Record.
    [
      Data { offset = 0; payload = "hello " };
      Data { offset = 7; payload = "world" };
    ]

let () = ihex |> Intel_hex.to_string |> print_endline
```

Also, you can of course read the IHEX object file from other sources:

```ocaml
In_channel.with_open_text "firmware.hex" Intel_hex.of_channel
```

## References

- [martinmroz/ihex](https://github.com/martinmroz/ihex)