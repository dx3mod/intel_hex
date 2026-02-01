# intel_hex

The Intel HEX manipulation library for OCaml provides functions to read, write, and create Intel HEX format data, which is commonly used in embedded systems programming.

## Usage

If you are using Dune, add the `intel_hex` library to your libraries stanza.

Here is an example that creates an IHEX object file with test data and then prints it:

```ocaml
Intel_hex.Record.
  [
      Extended_segment_address 0x0F;
      Data (0x0000, "Hello ");
      Data (0x0007, "World!");
      End_of_file;
  ]
|> Intel_hex.records_to_string 
|> print_endline
```
```
:02000002000FED
:0600000048656C6C6F20E6
:06000700576F726C6421CA
:00000001FF
```

Also, you can of course read the IHEX object file from other sources:

```ocaml
In_channel.with_open_text "data.hex" Intel_hex.object_of_channel
```
```ocaml
- : Intel_hex.Object.t =
{Intel_hex.Object.start_linear_address = 0;
 start_segment_address = {Intel_hex.Object.cs = 0; ip = 0};
 chunks = [(240, "Hello "); (247, "World!")]}
```

For more documentation you should read the [`mli`](./lib/intel_hex.mli) files.

## References

- [martinmroz/ihex](https://github.com/martinmroz/ihex)
- [unixdj/ihex](https://pkg.go.dev/github.com/unixdj/ihex)