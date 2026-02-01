(lang dune 3.6)

(version 0.3)

(name intel_hex)

(generate_opam_files true)

(source
 (github dx3mod/intel_hex))

(authors "Mikhail Lopatin <dx3mod@bk.ru>")

(maintainers "Mikhail Lopatin <dx3mod@bk.ru>")

(license MIT)

(package
 (name intel_hex)
 (synopsis "Intel HEX manipulation library")
 ;  (description "A longer description")
 (depends
  (ocaml
   (>= 4.14))
  (cstruct
   (>= 6.2)))
 (tags
  (embedded hex intelhex)))
