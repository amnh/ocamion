(** {1 Brents Method}
     Uses brents method, a combination of parabolic interpolation and golden
     section search movements, to find the local minimum of a bracketed region
     of a function.

     {b References}
     +

     +

*)


(** {2 Bracketing a Region} *)

(** A type definition for a function to bracket a minimum. *)
type 'a bracket_fn =
  (float -> 'a * float) -> float * ('a * float) ->
    (float * ('a * float)) * (float * ('a * float)) * (float * ('a * float))

(** Bracketing a region takes golden section searches to find a bracketed region
    starting from (0.2x,2.0x) where x is the initial point. *)
val bracket_region : ?v_min:float -> ?v_max:float -> 'a bracket_fn


(** {2 Optimization Routines} *)

(** [optimize ?max_iter ?v_min ?v_max ?tol ?epsilon ?braket f i] 
  
  
  
 *)
val optimize :
  ?max_iter:int -> ?v_min:float -> ?v_max:float -> ?tol:float ->
    ?epsilon:float -> ?bracket:'a bracket_fn -> (float -> 'a * float) ->
      float * ('a * float) -> float * ('a * float)

(** [optimize_multi ?max_iter ?v_min ?v_max ?tol ?epsilon ?braket ?converge f i]
  
  
  
 *)
val optimize_multi :
  ?max_iter:int -> ?v_min:float -> ?v_max:float -> ?tol:float ->
    ?epsilon:float -> ?bracket:'a bracket_fn -> (float array -> 'a * float) ->
      float array * ('a * float) -> float array * ('a * float)
