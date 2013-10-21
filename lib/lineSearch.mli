(** {1 Line Search}
 
    
    {b References}
    +

    +
*)

type warnings = [ `StepConvergence | `LargeInitialSlope ] list

(** [optimize ?epsilon ~gradient ~maxstep ~direction f i]
  Optimize the function [f] in the direction specified with a maximum step being
  [maxstep]. We itertively search from maxstep down to a minimum 
 
*)
val optimize :
  ?epsilon:float -> gradient:float array -> maxstep:float ->
    direction:float array -> (float array -> 'a * float) ->
      float array * ('a * float) -> float array * ('a * float)
