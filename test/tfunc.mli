module type OneTestFunction =
  sig
    val f     : float -> float
    val name  : string
    val range : (float * float) option
    val is_min: ?tol:float -> float -> bool
  end

module type MultiTestFunction =
  sig
    val f     : float array -> float
    val dim   : int option
    val range : (float * float) option
    val name  : string
    val is_min: ?tol:float -> float array -> bool
  end

module type StocMultiTestFunction =
  sig
    val f     : ?dist:(unit -> float) -> float array -> float
    val dim   : int option
    val range : (float * float) option
    val name  : string
    val is_min: ?tol:float -> float array -> bool
  end

val multi_dim_modules : (module MultiTestFunction) list

val stoc_multi_dim_modules : (module StocMultiTestFunction) list

val one_dim_modules : (module OneTestFunction) list
