val optimize :
  ?epsilon:float ->
  gradient:float array ->
  maxstep:float ->
  direction:float array ->
  (float array -> 'a * float) ->
  float array * ('a * float) -> float array * ('a * float)
