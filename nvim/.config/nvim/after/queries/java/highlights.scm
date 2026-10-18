;; extends

; Type declarations are @type in the stock query, the same capture as every
; use of the type, so the theme can't tell them apart. Give the declaring
; name its own capture. Constructors too: their name is also stock @type.
(class_declaration
  name: (identifier) @alabaster.definition)

(interface_declaration
  name: (identifier) @alabaster.definition)

(enum_declaration
  name: (identifier) @alabaster.definition)

(record_declaration
  name: (identifier) @alabaster.definition)

(annotation_type_declaration
  name: (identifier) @alabaster.definition)

(constructor_declaration
  name: (identifier) @alabaster.definition)

; Scoped names, where they are introduced: fields, parameters, locals and the
; variables lambdas, loops, catch, try-with-resources and patterns bind.
(field_declaration
  declarator: (variable_declarator
    name: (identifier) @alabaster.local))

(local_variable_declaration
  declarator: (variable_declarator
    name: (identifier) @alabaster.local))

(formal_parameter
  name: (identifier) @alabaster.local)

(spread_parameter
  (variable_declarator
    name: (identifier) @alabaster.local))

(catch_formal_parameter
  name: (identifier) @alabaster.local)

(enhanced_for_statement
  name: (identifier) @alabaster.local)

(resource
  name: (identifier) @alabaster.local)

(instanceof_expression
  name: (identifier) @alabaster.local)

(lambda_expression
  parameters: (identifier) @alabaster.local)

(inferred_parameters
  (identifier) @alabaster.local)
