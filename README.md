# <img src="https://i.ibb.co/kvh7P4p/lastihexlohgo-001.png" width="50" />  Intel_hex  

A library for parsing and generating Intel HEX (also known as IHEX) objects. This format is commonly used to represent compiled program code and data that is loaded into a microcontroller, flash memory, or ROM in embedded systems programming.


## Quick start

You can install the `intel_hex` library using the [OPAM] package manager or any other method you prefer.

```console
$ opam install intel_hex
```

You can also get the latest version of the upstream (developer) branch.
```console
$ opam pin intel_hex.dev https://github.com/dx3mod/intel_hex.git
```

If you are using [Dune], please add the `intel_hex` library to your dependencies.

### In use

Here is an example of how to create an Intel HEX file with test data and print it:
```ocaml
Intel_hex.Record.
[
  Extended_linear_address 0x0F;
  Data (0x0000, "Hello ");
  Data (0x0007, "World!");
  End_of_file;
]
|> Intel_hex.Encode.into_string 
|> print_endline
```
```
:02000004000FEB
:0600000048656C6C6F20E6
:06000700576F726C6421CA
:00000001FF
```

Also, you can read Intel HEX objects from any source, of course.

```ocaml
In_channel.with_open_text "data.hex" Intel_hex.Decode.from_channel
```
```ocaml
- : Intel_hex.Object.t =
[Intel_hex.Record.Extended_linear_address(0x000F);
 Intel_hex.Record.Data(0x0000, "Hello ");
 Intel_hex.Record.Data(0x0007, "World!");
 Intel_hex.Record.End_of_file]
```

For more details, see [API references](https://ocaml.org/p/intel_hex/latest/doc/index.html) and [`examples/`](./examples/) directory.

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
