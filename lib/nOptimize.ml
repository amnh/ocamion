
module type OPT =
  sig
    val optimize :
      ?max_iter:int -> ?tol:float ->
        (float array -> 'a * float) -> (float array * ('a * float)) -> (float array * ('a * float))
  end

module Bfgs : OPT =
  struct
    let optimize ?max_iter ?tol f fp = Bfgs.optimize ?max_iter ?tol f fp
  end

module BrentMulti : OPT =
  struct
    let optimize ?max_iter ?tol f fp = Brents.optimize_multi ?max_iter ?tol f fp
  end

module Simplex : OPT =
  struct
    let optimize ?max_iter ?tol f fp = Simplex.optimize ?max_iter ?tol f fp
  end

module Subplex : OPT =
  struct
    let optimize ?max_iter ?tol f fp = Subplex.optimize ?max_iter ?tol f fp
  end
