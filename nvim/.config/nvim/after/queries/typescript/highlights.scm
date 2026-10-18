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

; Scoped names, where they are introduced: variables (incl. destructuring),
; parameters, class fields, loop and catch bindings.
(variable_declarator
  name: (identifier) @alabaster.local)

(array_pattern
  (identifier) @alabaster.local)

(object_pattern
  (shorthand_property_identifier_pattern) @alabaster.local)

(pair_pattern
  value: (identifier) @alabaster.local)

(required_parameter
  pattern: (identifier) @alabaster.local)

(optional_parameter
  pattern: (identifier) @alabaster.local)

(arrow_function
  parameter: (identifier) @alabaster.local)

(public_field_definition
  name: (property_identifier) @alabaster.local)

(for_in_statement
  left: (identifier) @alabaster.local)

(catch_clause
  parameter: (identifier) @alabaster.local)

; Later patterns win, so these come last: a top-level const is part of what
; the module exposes, and a const holding a function is a function.
(program
  [
    (lexical_declaration
      (variable_declarator
        name: (identifier) @alabaster.definition))
    (export_statement
      (lexical_declaration
        (variable_declarator
          name: (identifier) @alabaster.definition)))
  ])

(variable_declarator
  name: (identifier) @alabaster.definition
  value: [
    (arrow_function)
    (function_expression)
  ])
