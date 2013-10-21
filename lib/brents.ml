open Internal
open Numerical

(** {2 Bracketing a Region} *)

(** A type definition for a function to bracket a minimum. *)
type 'a bracket_fn =
  f:(float -> 'a * float) -> float * ('a * float) ->
    (float * ('a * float)) * (float * ('a * float)) * (float * ('a * float))

(** A general helper function for bracketing a minimum. *)
let bracket_region ?(v_min=neg_infinity) ?(v_max=infinity) ~f o' =
  let minmax value = max (min v_max value) v_min in
  let (=.) a b = epsilon > (abs_float (a-.b)) in
  let rec create_scaled (v,_) s = 
    let vs = minmax (v *. s) in let fvs = f vs in
    (vs,fvs)
  and push_left a b _ = (create_scaled a 0.5),a,b
  and push_right _ b c = b,c,(create_scaled c 2.0)
  and bracket_region ((l,(_,fl)) as low) ((_,(_,fm)) as med) ((h,(_,fh)) as hi) =
    if l =. h then (low,med,hi)       (* converged *)
    else if fl =. fm && fm =. fh then (* converged; flat  *)
      (low,med,hi) (* TODO: flat warning message. *)
    else if fl <= fm && fm <= fh then (* increasing *)
      let a,b,c = push_left low med hi in
      bracket_region a b c
    else if fl >= fm && fm >= fh then (* decreasing *)
      let a,b,c = push_right low med hi in
      bracket_region a b c
    else if fm <= fl && fm <= fh then (* a bracket! *)
      (low,med,hi)
    else begin (* bracketed a maximum... *)
      (* let us do something gracefully, push ourselves to the minimum on the
         left or right, and continue with the algorithm. *)
      if fl <= fh 
        then let a,b,c = push_left  low med hi in bracket_region a b c
        else let a,b,c = push_right low med hi in bracket_region a b c
    end
  in
  bracket_region (create_scaled o' 0.2) o' (create_scaled o' 2.0)


(** {2 Optimization Routine} *)

(** Uses a combination of golden section searches and parabolic fits to find the
    optimal value of a function of one variable. **)
let optimize ?(max_iter=200) ?(v_min=neg_infinity) ?(v_max=infinity)
             ?(tol=tolerance) ?(epsilon=epsilon) ?(bracket=bracket_region ~v_min ~v_max)
              ~f orig =
  (*-- ensure value falls between range; if using one *)
  let minmax value = max (min v_max value) v_min in
  (*-- approximation of equality; based on optional argument above *)
  let (=.) a b = epsilon > (abs_float (a-.b)) in
  (*-- brents method as in Numerical Recipe in C; 10.2 *)
  let rec brent ((x,(_,fx)) as x') ((w,(_,fw)) as w') ( v') a b d e iters pu =
    let (v,(_,fv))  = v' in
    let xm = (a +. b) /. 2.0
    and tol1 = tol *. (abs_float x) +. epsilon in
    (* check ending conditions *)
    if iters > max_iter then begin 
      x' (* TODO: warning/report maximum iterations hit *)
    end else if (abs_float (x-.xm)) <= ((2.0 *. tol) -. (b -. a) *. 0.5) then
      x'
    else begin
      let d,e =
        if (abs_float e) > tol1 then begin
          (* calculate the abscissa *)
          let r = (x -. w) *. (fx -. fv) 
          and q = (x -. v) *. (fx -. fw) in
          let p = ((x -. v) *. q) -. ((x-.w) *. r) in
          let q = 2.0 *. (q -. r) in
          let p = if q > 0.0 then ~-. p else p in
          let q = abs_float q in
          (* the acceptability of the parabolic fit? *)
          if (abs_float p) >= (abs_float (0.5 *. q *. e))
             || p <= q *. (a -. x) || p >= q *. (b -. x) then
            (* do a golden section instead of parabolic fit *)
            let e = if x >= xm then a-.x else b -. x in
            let d = golden *. e in
            d,e
          else begin
            (* take the parabolic step *)
            let d_new = p /. q in
            let u = x +. d_new in
            let d,e = 
              if (u -. a) < (tol1 *. 2.0) || (b -. u) < (tol1 *. 2.0) 
                then copysign tol1 (xm -. x),d
                else d_new,d
            in
            d,e
          end
        end else begin
          let e = if x >= xm then a -. x else b -. x in
          let d = golden *. e in
          d,e
        end
      in
      (* the ONLY function evalution for each iteration *)
      let u =
        if (abs_float d) >= tol1
          then minmax (x+.d)
          else minmax (x+.(copysign tol1 d))
      in
      let fu = f u in
      let u',fu = (u,fu), snd fu in
      (* what to do with results for next iteration *)
      if pu = u then
        begin if fx < fu then x' else u' end
      else if fu <= fx then begin
        let a,b = if u >= x then x,b else a,x in
        brent u' x' w' a b d e (iters+1) u
      end else begin
        let a,b = if u < x then u,b else a,u in
        if fu <= fw || w =. x
          then brent x' u' w' a b d e (iters+1) u
          else brent x' w' u' a b d e (iters+1) u
      end
    end
  in
  let (lv,_),m,(hv,_) = bracket ~f orig in
  brent m m m lv hv 0.0 0.0 0 (fst m)


(** {2 Convergence for Optimization} *)

type converge =
  tol:float -> epsilon:float -> prev_array:float array -> prev_cost:float ->
    new_array:float array -> new_cost:float -> bool

let converge_one_pass ~tol:_ ~epsilon:_ ~prev_array:_ ~prev_cost:_ ~new_array:_ ~new_cost:_ =
  false

and converge_vec ~tol:_ ~epsilon ~prev_array ~prev_cost:_ ~new_array ~new_cost:_ =
  let diff = sub_vec prev_array new_array in
  Array.fold_left (fun acc dx -> acc && (eq_float_abs ~epsilon 0.0 dx)) true diff

and converge_cost ~tol:_ ~epsilon ~prev_array:_ ~prev_cost ~new_array:_ ~new_cost =
  eq_float_abs ~epsilon prev_cost new_cost


(** {2 Multi-Dimensional Optimization Routine} *)

(** Meta function to accomidate multi-dimensional data. The converge function
    deals with how to define convergence, by default we converge at cost. *)
let optimize_multi ?(max_iter=200) ?(v_min=minimum) ?(v_max=300.0)
          ?(tol=tolerance) ?(epsilon=epsilon) ?(bracket=bracket_region ~v_min ~v_max)
          ?(converge=converge_one_pass) ~f orig =
  let rec do_single costs i ((a,x) as data) =
    let f = update_single i a in
    let (v,fv) = optimize ~max_iter ~v_min ~v_max ~tol ~epsilon ~bracket ~f (a.(i),x) in
    let () = Array.set a i v in
    if i = (Array.length a)-1 then
      let prev_array,prev_cost = costs in
      if converge ~tol ~epsilon ~prev_array ~prev_cost ~new_array:a ~new_cost:(snd fv)
        then data
        else do_single (a,snd fv) 0 (a,fv)
    else
      do_single costs (i+1) (a,fv)
  and update_single i a v =
    let a = Array.copy a in
    let () = Array.set a i v in
    f a
  in
  do_single (fst orig,snd @@ snd orig) 0 orig
