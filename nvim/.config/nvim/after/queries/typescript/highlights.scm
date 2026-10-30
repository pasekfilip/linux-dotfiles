;; extends

; Type declarations fall under the stock (type_identifier) @type, the same
; capture as every use of the type. Give the declaring name its own capture.
; tsx inherits this file through its `; inherits: typescript`.
(class_declaration
  name: (type_identifier) @alabaster.definition)

(abstract_class_declaration
  name: (type_identifier) @alabaster.definition)

(interface_declaration
  name: (type_identifier) @alabaster.definition)

(type_alias_declaration
  name: (type_identifier) @alabaster.definition)

(enum_declaration
  name: (identifier) @alabaster.definition)

; A const holding a function is a function.
(variable_declarator
  name: (identifier) @alabaster.definition
  value: [
    (arrow_function)
    (function_expression)
  ])

; break and continue leave a block the way return leaves a function, so they
; take return's capture and look like it in every style.
[
  "break"
  "continue"
] @keyword.return
