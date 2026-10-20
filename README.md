# intel_hex

[Intel HEX] parsing and manipulation library.

This format is commonly used to represent compiled program code and data
that is loaded into a microcontroller, flash memory, or ROM in embedded
systems programming.

## Quick start

You can install the `intel_hex` library using the [OPAM] package manager or any other method you prefer.
If you are using [Dune], please add the `intel_hex` library to your dependencies.

## In use

The library provides a simple API for parsing and creating Intel HEX files. To create an Intel HEX file, you can use the following code:
```ocaml
Intel_hex.Record.
[
  Extended_linear_address 0x0F;
  Data (0x0000, "Hello ");
  Data (0x0007, "World!");
  End_of_file;
]
|> Intel_hex.Object.to_string
|> print_endline
```
```text
:02000004000FEB
:0600000048656C6C6F20E6
:06000700576F726C6421CA
:00000001FF
```

And to parse a string containing an Intel HEX file:

```ocaml
":0600000048656C6C6F20E6\n:06000700576F726C6421CA"
|> Intel_hex.Object.of_string
(* - : Intel_hex.Object.t =
  [ Intel_hex.Record.Data (0, "Hello "); 
    Intel_hex.Record.Data (7, "World!") ] *)
```

However, the library also provides a module for working with memory images built from Intel HEX files or other sources.

```ocaml
Intel_hex.Memory.of_string ~block_size:6 "Hello World!"
(* - : Intel_hex.Memory.t =
 [ Intel_hex.Memory.Segment(0x0000, "Hello ");
   Intel_hex.Memory.Segment(0x0006, "World!") ] *)
```

For more details, see the [API reference](https://ocaml.org/p/intel_hex/latest/doc/index.html) and the [`examples/`](./examples/) directory.

## References

Format description

- <https://en.wikipedia.org/wiki/Intel_HEX>
- <https://www.tasking.com/documentation/smartcode/ctc/reference/objfmt_hex.html>

Reference implementations

- [martinmroz/ihex](https://github.com/martinmroz/ihex)
- [unixdj/ihex](https://pkg.go.dev/github.com/unixdj/ihex)

## License

The project is licensed under [the MIT License](./LICENSE), which allows for all permissions.
Just use it and enjoy yourself without fear. We are always open to pull requests!

[OPAM]: https://opam.ocaml.org/
[Dune]: https://dune.build
[Intel HEX]: https://en.wikipedia.org/wiki/Intel_HEX