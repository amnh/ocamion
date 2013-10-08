val bracket_region :
  ?v_min:float ->
  ?v_max:float ->
  (float -> 'a * float) ->
  float * ('a * float) ->
  (float * ('a * float)) * (float * ('a * float)) * (float * ('a * float))

val optimize :
  ?max_iter:int ->
  ?v_min:float ->
  ?v_max:float ->
  ?tol:float ->
  ?epsilon:float ->
  ?bracket:((float -> 'a * float) ->
            float * ('a * float) ->
            (float * ('a * float)) * (float * ('a * float)) *
            (float * ('a * float))) ->
  (float -> 'a * float) -> float * ('a * float) -> float * ('a * float)

val optimize_multi :
  ?max_iter:int ->
  ?v_min:float ->
  ?v_max:float ->
  ?tol:float ->
  ?epsilon:float ->
  ?bracket:((float -> 'a * float) ->
            float * ('a * float) ->
            (float * ('a * float)) * (float * ('a * float)) *
            (float * ('a * float))) ->
  (float array -> 'a * float) ->
  float array * ('a * float) -> float array * ('a * float)
