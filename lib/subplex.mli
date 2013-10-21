(** {1 Subplex Method}
    The Subplex method is a generalization to a number of algorithms, paramount
    the Nelder-Mead simplex method, with alternating variables, and Nelder-Mead
    Simplex with restart. The advantages are outlined in the referenced paper in
    section 5.3.6. The method is useful for noisy functions, or functoins of
    high-dimension. Low dimension functions, due to the complexity of limiting
    the search space via sub-domains may not perform as well as other methods
    --this at least has been our experience in using the method.

    How sub-domains are generated and the stopping conditions can be changed
    through the optional arguments of the [optimize] function.

    {b References}
    + T. H. Rowan. Functional Stability Analysis of Numerical Algorithms. 1990 *)


(** {2 Functional Settings} *)

(** The Subplex strategy contains a simplex strategy and added features *)
type subplex_strategy = 
  { simplex : Simplex.simplex_strategy;
        psi : float;              (** The Simplex Reduction coefficient *)
      omega : float;              (** The Step Reduction coefficient *)
      nsmin : int;                (** Minimum subspace dimension; or 2 *)
      nsmax : int;                (** Maximum subspace dimension; or 5 *)
  }

(** Default Simplex Strategy defined by FSAoNA paper *)
val default_subplex : subplex_strategy

(** Determine the subspaces by a randomization of the vector, and randomizing
    the size of the subspaces; conditions will match the strategy *)
val rand_subspace : subplex_strategy -> float array -> int array list

(** A subplex routine that splits up an delta array into subspaces that match
    the criteria found in the subplex paper section 5.3.3 *)
val find_subspace : subplex_strategy -> float array -> int array list

(** Define how termination of the algorithm should be done. This is outlined in
    the paper, section 5.3.4. This test, because of a noisy function, uses the
    distance between the vertices of the simplex to see if the function has
    converged. *)
val subplex_termination :
  subplex_strategy -> float -> float array -> float array -> float array -> bool


(** {2 Optimization Function} *)

(** [optimize ?subplex_stragegy ?tol ?max_iter ?select_subspace f i] *)
val optimize :
  ?subplex_strategy:subplex_strategy -> ?tol:float -> ?max_iter:int ->
    ?select_subspace:(subplex_strategy -> float array -> int array list) ->
      f:(float array -> 'a * float) -> float array * ('a * float) -> float array * ('a * float)
