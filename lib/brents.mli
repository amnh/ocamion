(** {1 Brents Method}
     Uses brents method, a combination of parabolic interpolation and golden
     section search movements, to find the local minimum of a bracketed region
     of a function.

     {b References}
      + Brent, R.P. "Algorithms for Minimization without Derivatives", 1973
      + Press, W.H, Teukoisky, S.A., Vetterling W.T,. Flannery, B.P., Numerical
        Recipes - The Art of Scientific Computing, 2007 *)


(** {2 Bracketing a Region} *)

(** A type definition for a function to bracket a minimum around a test point. *)
type 'a bracket_fn =
  f:(float -> 'a * float) -> float * ('a * float) ->
    (float * ('a * float)) * (float * ('a * float)) * (float * ('a * float))

(** Bracketing a region takes golden section searches to find a bracketed region
    starting from (0.2x,2.0x) where x is the initial point. *)
val bracket_region : ?v_min:float -> ?v_max:float -> 'a bracket_fn


(** {2 Optimization Routine} *)

(** [optimize ?max_iter ?v_min ?v_max ?tol ?epsilon ?braket f i] 
    Optimize a function of one variable using parabolic fits and golden section
    searches. This method does not require a derivative, but, due to the
    parabolic fits, does assume smoothness of the function. One function
    evaluation is done for each iteration of the algorithm, so [max_iter] will
    be approximately (due to first bracketing a region) the number of calls to
    the function being optimized. *)
val optimize :
  ?max_iter:int -> ?v_min:float -> ?v_max:float -> ?tol:float ->
    ?epsilon:float -> ?bracket:'a bracket_fn -> f:(float -> 'a * float) ->
      float * ('a * float) -> float * ('a * float)


(** {2 Convergence for Multi-Dimensional Optimization} *)

(** A type to define a convergence function for the multi-dimensional
    optimization routine. *)
type converge =
  tol:float -> epsilon:float -> prev_array:float array -> prev_cost:float ->
    new_array:float array -> new_cost:float -> bool

(** Converge the multidimensional algorithm with one pass through the array. *)
val converge_one_pass : converge

(** Converge if the array has not changed. *)
val converge_vec : converge

(** Converge if the final cost has not changed. *)
val converge_cost : converge


(** {2 Multi-Dimensional Optimization Routine} *)

(** [optimize_multi ?max_iter ?v_min ?v_max ?tol ?epsilon ?bracket ?converge f i]
    Uses brents method on each variable of the array in order until the
    convergence function returns true --the converge function is called each
    after each round of all elements of vector are independently optimized. *)
val optimize_multi :
  ?max_iter:int -> ?v_min:float -> ?v_max:float -> ?tol:float ->
    ?epsilon:float -> ?bracket:'a bracket_fn -> ?converge:converge ->
      f:(float array -> 'a * float) -> float array * ('a * float) ->
        float array * ('a * float)

