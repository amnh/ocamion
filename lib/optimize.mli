
val optimize :
    ?max_iter:int -> ?epsilon:float -> ?max_step:float -> ?tol:float
        -> (float array -> 'a * float) -> (float array * ('a * float))
            -> (float array * ('a * float))
