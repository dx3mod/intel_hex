(lang dune 3.6)

(name intel_hex)

(version 0.4.1)

(generate_opam_files true)

(source
 (github dx3mod/intel_hex))

(authors "Mikhail Lopatin <dx3mod@bk.ru>")

(maintainers "Mikhail Lopatin <dx3mod@bk.ru>")

(license MIT)

(package
 (name intel_hex)
 (synopsis "Intel HEX manipulation library")
 (description
  "A Intel HEX manipulation library for parsing and generating Intel HEX (also known as IHEX) objects")
 (depends
  (ocaml
   (>= 4.14))
  ohex
  (alcotest :with-test))
 (tags
  (ihex intelhex embedded bytes hex)))
