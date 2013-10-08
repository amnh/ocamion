(** {1 Numerical Optimization Module}
    This module unifies the signatures of the multi-dimensional optimization
    routines by hiding and exploiting defaults to the functions in question.
    This is used when one would like to test the efficacy of the functions
    easily.
    
    Accessing the optimization routines directly may allow better control over
    the routine, but this module takes care of most of the parameters. Further
    details of these routines can be found in their individual modules. *)

module type OPT =
  sig
    val optimize :
      ?max_iter:int -> ?tol:float ->
        (float array -> 'a * float) -> (float array * ('a * float)) -> (float array * ('a * float))
  end


(** Broyden-Fletcher-Goldfarb-Shanno optimization method is a
    Quasi-Newtons method routine. See Numerical Recipes 10.7 for details. *)
module Bfgs    : OPT

(** Brents method is traditionally done on a single variable (Numerical Recipes
    10.3), this is implemented such that each element of the vector is optimized
    in succession, until convergence with a maximum number of total optimization
    rounds equal to 500 / [n]. *)
module BrentMulti   : OPT

(** A simplex is an [n]+1 dimensional structure. The simplex method uses these
    points in the space and act like an 'ameoba' searching for an optimium. For
    further details see, Numerical Recipes 10.5. This implementation masks the
    simplex termination test, the strategy and step array for generating an
    initial solution. *)
module Simplex : OPT

(** A subplex is a generalization of the simplex where subspaces of the
    dimensional vector are optimized with the simplex routine. More details can
    be found in, 'Functional Stability Analysis of Numerical Algorithms'. This
    implementation masks the subplex_strategy, how subspaces are selected, and
    the simplex termination function. *)
module Subplex : OPT
