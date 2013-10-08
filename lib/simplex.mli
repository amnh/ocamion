type 'a simplex =
  (float array * ('a * float)) array

type simplex_strategy = {
  alpha : float;
  beta : float;
  gamma : float;
  delta : float;
}

val default_simplex : simplex_strategy

val simplex_termination_stddev : float -> 'a simplex -> bool

val simplex_termination_stationary : float -> 'a simplex -> bool

val centroid : 'a simplex -> int -> float array

val random_simplex :
  (float array -> 'a * float) -> float array * ('a * float) -> float array option -> 'a simplex

val initial_simplex :
  (float array -> 'a * float) -> float array * ('a * float) -> float array option -> 'a simplex

val simplex_method :
  ?termination_test:(float -> 'a simplex -> bool) ->
  ?tol:float ->
  ?simplex_strategy:simplex_strategy ->
  ?max_iter:int ->
  ?step:float array option ->
  (float array -> 'a * float) ->
  float array * ('a * float) -> float array * ('a * float)
