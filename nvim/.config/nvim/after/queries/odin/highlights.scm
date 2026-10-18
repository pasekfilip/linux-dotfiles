;; extends

; Names where they are introduced, split in two like y9nika: what the package
; exposes (top level) and what lives in a scope. Uses stay plain. Shapes are
; the ones nvim-treesitter's odin/locals.scm uses for its definitions; the
; trailing token keeps the right-hand side of `x := y` out of the capture.

; Top level: what the package exposes.
(source_file
  (procedure_declaration
    . (identifier) @alabaster.definition))

(source_file
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
    (const_declaration
      (identifier) @alabaster.definition
      "::")
  ])

(source_file
  (variable_declaration
    (identifier) @alabaster.definition
    ":="))

(source_file
  (var_declaration
    (identifier) @alabaster.definition
    ":"))

; Scoped: parameters and anything declared inside a block. Inside a proc,
; `x := 1` parses as assignment_statement, not variable_declaration.
(parameter
  (identifier) @alabaster.local
  ":")

(default_parameter
  (identifier) @alabaster.local
  ":=")

(assignment_statement
  (identifier) @alabaster.local
  ":=")

(block
  (var_declaration
    (identifier) @alabaster.local
    ":"))

(block
  (const_declaration
    (identifier) @alabaster.local
    "::"))

(for_statement
  (identifier) @alabaster.local
  "in")
