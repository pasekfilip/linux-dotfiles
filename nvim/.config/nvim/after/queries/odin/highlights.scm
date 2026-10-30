;; extends

; Definitions: procedure and type names, where they are declared -- the same
; rule as the java and typescript queries. Constants, globals and locals stay
; plain. The trailing "::" keeps the right-hand side out of the capture.
(procedure_declaration
  (identifier) @alabaster.definition)

[
  (struct_declaration
    (identifier) @alabaster.definition
    "::")
  (enum_declaration
    (identifier) @alabaster.definition
    "::")
  (union_declaration
    (identifier) @alabaster.definition
    "::")
  (bit_field_declaration
    (identifier) @alabaster.definition
    "::")
]

; break and continue leave a block the way return leaves a function, so they
; take return's capture and look like it in every style.
[
  "break"
  "continue"
] @keyword.return
