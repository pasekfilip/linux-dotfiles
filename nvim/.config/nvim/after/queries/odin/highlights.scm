;; extends

; y9nika's Odin query (y9san9/y9nika.nvim): only procedure names, where they
; are declared. Structs, constants, globals and locals stay plain. The richer
; version that also captured those is in git history (1bae3b3).
(procedure_declaration
  (identifier) @alabaster.definition)
