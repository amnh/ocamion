IFDEF COMPATIBILITY THEN

  let compatibility = true

  external (@@) : ('a -> 'b) -> 'a -> 'b = "%apply"
  external (|>) : 'a -> ('a -> 'b) -> 'b = "%revapply"

ELSE

  let compatibility = false

END

