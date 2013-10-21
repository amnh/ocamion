open Numerical

type 'a simplex = (float array * ('a * float)) array

type simplex_strategy = 
  { alpha : float;  (* The Reflection factor *)
     beta : float;  (* The Contraction factor *)
    gamma : float;  (* The Expansion factor *)
    delta : float;  (* The Shrinkage (Massive Contraction) factor *)
  } 

(** Default Simplex Strategy defined by NMS *)
let default_simplex =
  { alpha = 1.0; beta = 0.5; gamma = 2.0; delta = 0.5; }

(** Verify that the strategy elements are consistent with their intended
    transformation. Thus, avoids negative and fractional values in some. *)
let verify_strategy strat =
  (strat.alpha > 0.0) &&
  (strat.beta  > 0.0  && strat.beta  < 1.0) &&
  (strat.gamma > 0.0  && strat.gamma > strat.alpha) &&
  (strat.delta > 0.0  && strat.delta < 1.0)

(** Get the worst, second worst, and best element of the simplex. return the
    index so we know to replace the proper point. Here we sort the elements,
    although if the dimension is high, it may be worthwhile to do an O(n) pass
    through the array of elements in the simplex. *)
let get_simplex_hsl (simplex: 'a simplex) : int * int * int =
  let get_cost (_,(_,x)) = x in
  Array.sort (fun x y -> compare (get_cost y) (get_cost x)) simplex;
  (0, 1, ((Array.length simplex)-1))

(** General Simplex termination; this is done through the standard deviation of
    the elements of the simplex. *)
let simplex_termination_stddev tol simplex =
  let n_plus_one = float_of_int (Array.length simplex) in
  let mean =
    let s = Array.fold_left (fun acc (_,(_,x)) -> acc +. x) 0.0 simplex in
    s /. n_plus_one
  in
  let std_dev =
    Array.fold_left
      (fun acc (_,(_,x)) -> let y = x -. mean in acc +. (y *. y)) 0.0 simplex
  in
  let std_dev = (sqrt (std_dev /. (n_plus_one))) in
  std_dev < tol

(** Simplex termination test defined by Gill, Murray and Wright. This method
    looks to see that the points are in a stationary position. This is more
    appropriate for optimizing smooth functions. It can also be used for noisy
    functions, but would be equivlent to convergance of the simplex. *)
let simplex_termination_stationary tol simplex =
  let high,low =
    Array.fold_left
      (fun (hi,lo) (_,(_,x)) -> (max hi x),(min lo x))
      (~-.max_float, max_float)
      (simplex)
  in
  ((high-.low) /. (1.0 +. (abs_float low))) < tol

(** Calculate the centroid of a simplex. Defined by the mean of the values of
    the simplex excluding the highest (worst) point. *)
let centroid (simplex:'a simplex) h_i =
  let n = Array.length (fst simplex.(0)) in
  let c_array = Array.make n 0.0 in
  Array.iteri
    (fun s_i (r,_) ->
      if s_i = h_i then () else add_veci c_array r)
    simplex;
  for i = 0 to n-1 do
    c_array.(i) <- c_array.(i) /. (float_of_int n);
  done;
  c_array

(** Create a simplex point. All of the operations on a simplex are linear
    equations, and can be generalized to this function with different
    coefficients passed to it.
        n = x + coef (x - y)
    in each particular situation, the following
        reflection  - x = centroid, y = high point, coef =  alpha
        contraction - x = centroid, y = high point, coef = -beta
        expansion   - x = centroid, y = reflection, coef = -gamma
        shrink      - x = high point, y = all,      coef = -delta *)
let create_new_point f t strategy xvec yvec : float array * ('a * float) =
  let coef = match t with
    | `Reflection   ->     (strategy.alpha)
    | `Contraction  -> ~-. (strategy.beta)
    | `Expansion    -> ~-. (strategy.gamma)
    | `Shrink       -> ~-. (strategy.delta)
  in
  let ret = Array.copy xvec in
  for i = 0 to (Array.length xvec) - 1 do
    ret.(i) <- xvec.(i) +. (coef *. (xvec.(i) -. yvec.(i)))
  done;
  let fret = f ret in
  ret,fret

(** Set up the initial simplex by randomly selecting points *)
let random_simplex f (p,_) _ : 'a simplex =
  Array.init
    ((Array.length p)+1)
    (fun _ ->
      let p = Array.init (Array.length p) (fun _ -> Random.float 1.0) in
      p,f p)

(** Set up the initial simplex from a point and a step size *)
let initial_simplex f (p,fp) (step : float array option) =
  let step : float array = match step with
    | Some step -> step
    | None -> Array.init (Array.length p) (fun _ -> Random.float 5.0)
  in
  let simplex =
    Array.init
      ((Array.length p)+1)
      (fun i ->
        if i = 0 then
          (p,fp)
        else begin
          let x = Array.copy p in
          x.(i-1) <- x.(i-1) +. step.(i-1);
          x, f x
        end)
  in
  let get_cost (_,(_,x)) = x in
  Array.sort (fun x y -> compare (get_cost y) (get_cost x)) simplex;
  simplex

(* shrink involves modifying each point except the best *)
let shrink_simplex simplex f strategy i_l =
  let replace_simplex = Array.set in
  for i = 0 to (Array.length simplex)-1 do
    if i_l = i then ()
    else
      let s_i = create_new_point f `Shrink strategy
                                (fst simplex.(i_l)) (fst simplex.(i))
      in
      replace_simplex simplex i s_i
  done;
  ()

(** The simplex uses an n+1 dimensional figure to move, like an amoeba, around
    the surface. The extermities of the object are evaluated, the maximal values
    are modified, while the others are progressed through improvements. The
    four moves that can be done on the simplex are: reflection, expansion,
    contraction, and shrinkage. The degree to which these are done is modified
    by the strategy used. *)
let optimize ?(termination_test=simplex_termination_stddev) ?(tol=tolerance)
             ?(simplex_strategy=default_simplex) ?(max_iter=100) ?(step=None)
              ~f (p,fp) =
  (* wrap function to keep track of the number of evaluations *)
  let i = ref 0 in
  let f = (fun x -> incr i; f x) in
  let strategy = simplex_strategy in
  assert( verify_strategy strategy );
  (* set up some alias functions to make the algorithm more readable. *)
  let get_cost (_,(_,x)) = x in
  let replace_simplex = Array.set in
  let rec simplex_loop step simplex =
    let i_h,_,i_l = get_simplex_hsl simplex in
    let s_c = centroid simplex i_h in
    (* first do a reflection *)
    let r = create_new_point f `Reflection strategy s_c (fst simplex.(i_h)) in
    if (get_cost r) < (get_cost simplex.(i_l)) then begin
      (* since it's so good, do an expansion *)
      let e = create_new_point f `Expansion strategy s_c (fst r) in
      if (get_cost e) < (get_cost simplex.(i_l))
        then replace_simplex simplex i_h e
        else replace_simplex simplex i_h r
    end else begin
    (* do a contraction of the simplex instead *)
      let c =
        (* contract from the worst point *)
        if (get_cost simplex.(i_h)) < (get_cost r)
          then create_new_point f `Contraction strategy s_c (fst simplex.(i_h))
          else create_new_point f `Contraction strategy s_c (fst r)
      in
      if (get_cost c) < (min (get_cost r) (get_cost simplex.(i_h)))
        (* successful contraction *)
        then replace_simplex simplex i_h c
        (* contraction failed; shrink --massive contraction *)
        else shrink_simplex simplex f strategy i_l
    end;
    if ((not (termination_test tol simplex)) || !i < max_iter)
      then simplex
      else simplex_loop (step+1) simplex
  in
  (* setup the initial simplex *)
  let simplex = simplex_loop 0 (initial_simplex f (p,fp) step) in
  let _,_,best = get_simplex_hsl simplex in
  simplex.(best)

