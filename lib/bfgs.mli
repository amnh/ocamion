val optimize :
  ?max_iter:int ->
  ?epsilon:float ->
  ?max_step:float ->
  ?tol:float ->
  ?gradient:((float array -> float) -> float array -> float -> float array) ->
  ?line_search:(?epsilon:float ->
                gradient:float array ->
                maxstep:float ->
                direction:float array ->
                (float array -> 'a * float) ->
                float array * ('a * float) -> float array * ('a * float)) ->
  (float array -> 'a * float) ->
  float array * ('a * float) -> float array * ('a * float)
