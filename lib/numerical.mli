(** Numerical Functions *)

(** {6 Constants} *)

val tolerance : float
(** [Tolerance] Tolerance of floating point calculations for convergence. *)

val epsilon   : float
(** [Epsilon] Machine floating point precision. *)

val minimum   : float
(** [Minimum] Minimum for numerical calculations (2.0 * tolerance). *)

val pi : float
(** [pi] IEEE float closest to the true value of pi; (defined, 4.0 * atan 1.0) *)

val golden : float
(** [golden] constant for the golden ratio. *)


(** {6 Floating Point Functions} *)

val is_nan : float -> bool
(** is the floating point number the IEEE representation of NAN *)

val is_inf : float -> bool
(** is the floating point number +/- infinity *)

val is_zero : float -> bool
(** is the floating point number zero or sub-normal (effectively zero). *)

val eq_float_abs : epsilon:float -> float -> float -> bool
(** test equality by absolute difference. Usefull if range is known. *)

val eq_float_gsl : epsilon:float -> float -> float -> bool
(** test equality by relative difference. Same basic implementation as GSL. *)


(** {6 Numerical Derivative Functions} *)

val gradient : ?epsilon : float -> f:(float array -> float) -> float array -> float -> float array

val derivative : ?epsilon : float -> (float -> float) -> float -> float -> float

val dot_product : float array -> float array -> float


(** {6 Vector Math Functions} *)

val add_veci : float array -> float array -> unit
(** add two vectors without additional allocation; result in x *)

val sub_vec : float array -> float array -> float array
(** functional subtraction of two vectors *)

val matrix_map : (int -> int -> float -> float) -> float array array -> float array array
(** map a function over a matrix *)


(** {6 L^p Space Distance Functions} *)

val inf_norm_vec : float array -> float
(** The maximum value of a vector. *)

val two_norm_vec : float array -> float
(** The Euclidean norm *)

val one_norm_vec : float array -> float
(** The taxicab/manhattan distance *)



(** {6 Numerical Optimization Functions}

val brents_method :
    ?max_iter:int -> ?v_min:float -> ?v_max:float -> ?tol:float -> ?epsilon:float 
        -> (float -> 'a * float) -> float * ('a * float) -> float * ('a * float)
(** [brents_method ?i ?min ?max ?tol ?e o f] -> n Uses brents method, a
    combination of parabolic interpolation and golden section search, to find
    the local minimum near [o] of the function [f], bounded by [min] and [max].
    [i] and [tol] are used to control the number of iterations, tolerance,
    respectively. [o] is a pair of floating point numbers, with additional data,
    representing a point.  (See, Numerical Recipes in C; 10.2) *)

val brents_method_multi :
    ?max_iter:int -> ?v_min:float -> ?v_max:float -> ?tol:float -> ?epsilon:float 
        -> (float array -> 'a * float) -> (float array * ('a * float))
            -> (float array * ('a * float))
(** brents_method_multi ...] Generalization of the above function for brents
    method. We optimize each value in the array one by one and only ONCE. This
    was seen in RAxML 7.04; and possibility has some utility since we do not
    need to calculate the derivative of a vector which can be costly and may not
    work on routines with a number of discontinuities. *)

(* Not necessary to be exposed; here in case a situation requires it.
val line_search :
    ?epsilon:float -> (float array -> 'a * float) -> float array -> 
        'a * float -> float array -> float -> float array -> float array * ('a * float) * bool
(** [line_search ?e ?a ?i ?min f p fp g s d] does a line search along the
    gradient [g] and direction [d] of function [f] by point [p], attempting the
    longest step, of maximum distance [s] *) 
*)

val bfgs_method :
    ?max_iter:int -> ?epsilon:float -> ?max_step:float -> ?tol:float
        -> (float array -> 'a * float) -> (float array * ('a * float))
            -> (float array * ('a * float))
(** [bfgs_method ?i ?e ?s f init] uses bfgs method to approximate the hessian
    matrix of a function f with starting point init. *)

val simplex_method : 
    ?termination_test : (float -> 'a simplex -> bool) -> ?tol : float ->
    ?simplex_strategy : simplex_strategy -> ?max_iter:int -> ?step:float array option
        -> (float array -> 'a * float) -> (float array * ('a * float))
            -> (float array * ('a * float))
(** The simplex uses an n+1 dimensional figure to move, like an amoeba, around
    the surface. The extermities of the object are evaluated, where the maximal
    values are modified, while the others are progressed with improvements. The
    four moves that can be done on the simplex are, reflection, expansion,
    contraction, and shrinkage. The degree to which these are done is modified
    by the strategy used. *)

val subplex_method : 
    ?subplex_strategy : subplex_strategy -> ?tol:float -> ?max_iter:int
        -> (float array -> 'a * float) -> (float array * ('a * float))
            -> (float array * ('a * float))
(** The Subplex method is a generalization to a number of algorithms, paramount
    the Nelder-Mead simplex method, with alternating variables, and Nelder-Mead
    Simplex with restart. The advantages are outlined in the previously
    mentioned paper, in section 5.3.6. *) 
*)
