(** {1 Broyden-Fletcher-Goldfarb-Shanno Method}
  
  
  
    {b References}
  
*)


(** {2 Optimization Function} *)

(** [bfgs_method ?max_iter ?epsilon ?max_step ?tol ?gradient ?line_search f i]
    Initiates the BFGS method on [f] with initial value [i]. The optional
    parameters allows for defining better functions for guidence. 
    + [max_iter]    - Maximum number of iterations. An iteration is defined as a 
                    call to the line search funciton (below).
    + [epsilon]     - Defines the numerical convergence. This defines if two
                    floating point numbers are equal. This differs from tol.
    + [max_step]    - The maximum step size. The default is 10.0. This forces
                    the algorithm to move through the surface slower than just
                    the calculation slope of the gradient.
    + [tol]         - Tolerance of the numerical routine. This defines how close
                    to an optimal value is exceptional and should be accepted.
    + [gradient]    - A function to calculate the gradient of a point. If no
                    function is given, a straight-forward routine is used.
    + [line_search] - A function to search along a particular direction. If none
                    is given the LineSearch.optimize function is used. *)
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
