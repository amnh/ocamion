type subplex_strategy = {
  simplex : Simplex.simplex_strategy;
  psi : float;
  omega : float;
  nsmin : int;
  nsmax : int;
}

val default_subplex : subplex_strategy

val rand_subspace : subplex_strategy -> float array -> int array list

val find_subspace : subplex_strategy -> float array -> int array list

val subplex_termination :
  subplex_strategy -> float -> float array -> float array -> float array -> bool

val subplex_method :
  ?subplex_strategy:subplex_strategy ->
  ?tol:float ->
  ?max_iter:int ->
  ?select_subspace:(subplex_strategy -> float array -> int array list) ->
  (float array -> 'a * float) ->
  float array * ('a * float) -> float array * ('a * float)
