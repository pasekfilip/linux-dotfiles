;; extends

; Type declarations are @type in the stock query, the same capture as every
; use of the type, so the theme can't tell them apart. Give the declaring
; name its own capture. Constructors too: their name is also stock @type.
; Methods need nothing: stock @function.method is only on declarations.
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

; break and continue leave a block the way return leaves a function, so they
; take return's capture and look like it in every style.
[
  "break"
  "continue"
] @keyword.return
