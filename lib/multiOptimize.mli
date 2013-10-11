(** {1 Numerical Optimization Module}
    This module unifies the signatures of the multi-dimensional optimization
    routines by hiding and exploiting defaults to the functions in question.
    This is used when one would like to test the efficacy of the functions
    easily.
    
    Accessing the optimization routines directly may allow better control over
    the routine, but this module takes care of most of the parameters. Further
    details of these routines can be found in their individual modules. The
    [all] value contains a list of the contained modules. *)


(** {2 Types} *)

(** Define a module containing a single function to optimize a function. *)
module type MOPT =
  sig
    val name : string
    val optimize :
      ?max_iter:int -> ?tol:float -> (float array -> 'a * float) ->
        (float array * ('a * float)) -> (float array * ('a * float))
  end


(* {2 Implementations} *)

(** Broyden-Fletcher-Goldfarb-Shanno method *)
module Bfgs    : MOPT

(** Brents method with multiple dimensions *)
module BrentMulti   : MOPT

(** The Simplex method *)
module Simplex : MOPT

(** The Subplex method *)
module Subplex : MOPT


(** {2 Values} *)

(** A list of all the methods above. *)
val all : (module MOPT) list
