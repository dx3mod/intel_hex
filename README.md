# intel_hex

The Intel HEX manipulation library for OCaml provides functions to read, write, and create Intel HEX format data, which is commonly used in embedded systems programming.

## Usage

If you are using Dune, add the `intel_hex` library to your libraries stanza.

Here is an example that creates an IHEX object file with test data and then prints it:

```ocaml
Intel_hex.Record.[ Data (0x0000, "Hello "); Data (0x0007, "World!"); End_of_file ]
|> Intel_hex.records_to_string 
|> print_endline
```
```
:0600000048656C6C6F20E6
:06000700576F726C6421CA
:00000001FF
```

Also, you can of course read the IHEX object file from other sources:

```ocaml
In_channel.with_open_text "firmware.hex" Intel_hex.object_of_channel
```

For more documentation you should read the [`mli`](./lib/intel_hex.mli) files.

## References

- [martinmroz/ihex](https://github.com/martinmroz/ihex)
- [unixdj/ihex](https://pkg.go.dev/github.com/unixdj/ihex)