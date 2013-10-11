(** {1 Simplex Method}

    The simplex uses an n+1 dimensional figure to move, like an amoeba, around
    the surface. The extremities of the object are evaluated, the maximal values
    are modified, while the others are progressed through improvements. The four
    moves that can be done on the simplex are: reflection, expansion,
    contraction, and shrinkage. The degree to which these are done is modified
    by the strategy used.
    
    {b References} 
      +
      +
    *)


(** {2 Types} *)

(** Define a simplex as a collection of points with attached data *)
type 'a simplex =
  (float array * ('a * float)) array

(** Simplex strategy defines how to expand, contract, and reflect a simplex *)
type simplex_strategy = 
  { alpha : float;  (** The Reflection factor *)
     beta : float;  (** The Contraction factor *)
    gamma : float;  (** The Expansion factor *)
    delta : float;  (** The Shrinkage (Massive Contraction) factor *)
  } 


(** {2 Default Strategy} *)

(** Default Simplex Strategy defined by NMS.
    [{alpha = 1.0; beta = 0.5; gamma = 2.0; delta = 0.5;}] *)
val default_simplex : simplex_strategy


(** {2 Given Termination Functions} *)

(** termination is done through the standard deviation of the elements of the simplex. *)
val simplex_termination_stddev : float -> 'a simplex -> bool

(** Simplex termination test defined by Gill, Murray and Wright. This method
    looks to see that the points are in a stationary position. This is more
    appropriate for optimizing smooth functions. It can also be used for noisy
    functions, but would be equivalent to convergence of the simplex. *)
val simplex_termination_stationary : float -> 'a simplex -> bool


(** {2 Given Initialization Functions} *)

(** Set up the initial simplex by randomly selecting points *)
val random_simplex :
  (float array -> 'a * float) -> float array * ('a * float) -> float array option -> 'a simplex

(** Set up the initial simplex from a point and a step size *)
val initial_simplex :
  (float array -> 'a * float) -> float array * ('a * float) -> float array option -> 'a simplex


(** {2 Optimization Routines} *)

(** [optimize ?termination_test ?tol ?simplex_strategy ?max_iter ?step f i]
  
  

  *)
val optimize :
  ?termination_test:(float -> 'a simplex -> bool) -> ?tol:float ->
    ?simplex_strategy:simplex_strategy -> ?max_iter:int ->
      ?step:float array option -> (float array -> 'a * float) ->
        float array * ('a * float) -> float array * ('a * float)
