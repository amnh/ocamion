
module type MOPT =
  sig
    val name : string
    val optimize :
      ?max_iter:int -> ?tol:float ->
        f:(float array -> 'a * float) -> (float array * ('a * float)) -> (float array * ('a * float))
  end

module Bfgs : MOPT =
  struct
    let name = "BFGS"
    let optimize ?max_iter ?tol ~f fp = Bfgs.optimize ?max_iter ?tol ~f fp
  end

module BrentMulti : MOPT =
  struct
    let name = "Brent"
    let optimize ?max_iter ?tol ~f fp = Brents.optimize_multi ?max_iter ?tol ~f fp
  end

module Simplex : MOPT =
  struct
    let name = "Simplex"
    let optimize ?max_iter ?tol ~f fp = Simplex.optimize ?max_iter ?tol ~f fp
  end

module Subplex : MOPT =
  struct
    let name = "Subplex"
    let optimize ?max_iter ?tol ~f fp = Subplex.optimize ?max_iter ?tol ~f fp
  end

let all : (module MOPT) list =
  [(module Bfgs); (module BrentMulti); (module Simplex); (module Subplex);]
