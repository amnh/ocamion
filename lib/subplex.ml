open Numerical

(** The Subplex strategy contains a simplex strategy and added features *)
type subplex_strategy = 
  { simplex : Simplex.simplex_strategy;
        psi : float;              (** The Simplex Reduction coefficient *)
      omega : float;              (** The Step Reduction coefficient *)
      nsmin : int;                (** Minimum subspace dimension; or 2 *)
      nsmax : int;                (** Maximum subspace dimension; or 5 *)
  }

(** Default Simplex Strategy defined by FSAoNA paper *)
let default_subplex =
  { simplex = Simplex.default_simplex; omega = 0.1; psi = 0.25; nsmin = 2; nsmax = 5; }

(** Takes a function [f] for an array [ray] ,and a subpsace [sub], like (0,2),
    that replaces the elements of the new array into [ray] according to the
    subspace association. We keep this function functional by copying the array
    each time, although it may not be necessary. *)
let function_of_subspace f ray sub_assoc =
  (fun sub ->
    let ray = Array.copy ray in
    let () = Array.iteri (fun i x -> ray.(x) <- sub.(i) ) sub_assoc in
    f ray)

(** Return the vector that represents the subspace *)
let make_subspace_vector subs x =
  Array.init (Array.length subs) (fun i -> x.( subs.(i) ))

(** Replace elements of a subspace vector into the main vector *)
let replace_subspace_vector sub nx x =
  Array.iteri (fun i _ -> x.( sub.(i) ) <- nx.(i)) sub

(** A subplex routine to find the optimal step-size for the next iteration of
    the algorithm. The process is outlined in 5.3.2. Each step, the vector is
    re-scaled in proportion to how much progress was made previously. If little
    progress is made then step is reduced and if onsiderable progress is made
    then it is increased. Lower and Upper Bounds in the strategy ensure we do
    not do anything rash. *)
let find_stepsize strat nsubs x dx steps =
  let n = Array.length x
  and sign x = if x >= 0.0 then 1.0 else -1.0
  and minmax x lo hi = 
    let lo = min lo hi and hi = max lo hi in
    max lo (min x hi)
  in
  (* find the scale factor for new step *)
  let stepscale =
    if nsubs > 1 then begin
      let stepscale = (one_norm_vec dx) /. (one_norm_vec steps) in
      minmax stepscale (1.0/.strat.omega) strat.omega
    end else begin
      strat.psi
    end
  in
  (* scale step vector by stepscale *)
  let nstep = Array.map (fun x -> x *. stepscale) steps in
  (* orient step in the proper direction *)
  for i = 0 to n-1 do
    if dx.(i) = 0.0
      then nstep.(i) <- ~-. (nstep.(i))
      else nstep.(i) <- (sign dx.(i)) *. (nstep.(i))
  done;
  nstep

(** Determine the subspaces by a randomization of the vector, and randomizing
    the size of the subspaces; conditions will match the strategy *)
let rand_subspace strat vec : int array list =
  let randomize ar = 
    let l = Array.length ar - 1 in
    for i = 0 to l do
      let rnd = i + Random.int (l - i + 1) in
      let tmp = ar.(i) in
      ar.(i) <- ar.(rnd);
      ar.(rnd) <- tmp;
    done;
    ar
  in
  let n = Array.length vec in
  let rec take acc n lst = match lst with
    | _ when n = 0 -> List.rev acc,lst
    | []           -> assert false
    | x::lst       -> take (x::acc) (n-1) lst
  in
  let rec continually_take taken acc lst =
    if taken = n then
      List.rev acc
    else if (n - taken) < 2 * strat.nsmin then
      continually_take (n) (lst::acc) []
    else begin
      let lo = min strat.nsmax (n-taken) in
      let r = strat.nsmin + (Random.int  (lo - strat.nsmin)) in
      if n-(r+taken) < strat.nsmin
        then continually_take taken acc lst
        else begin
          let f,l = take [] r lst in
          continually_take (taken+r) (f::acc) l
        end
    end
  in
  vec |> Array.mapi (fun i _ -> i)
      |> randomize
      |> Array.to_list
      |> continually_take 0 []
      |> List.map (Array.of_list)

(** A subplex routine that splits up an delta array into subspaces that match
    the criteria found in the subplex paper section 5.3.3 *)
let find_subspace strat vec =
  let n = Array.length vec in
  (* resolve a specific value of k *)
  let rec resolve_k k lvec : float =
    let rec left (acc:float) (i:int) lvec : float  = match lvec with
      | []            -> acc /. (float_of_int k)
      | xs when i = k -> right (acc /. (float_of_int k)) 0.0 xs
      | (_,x)::tl     -> left (acc +. (abs_float x)) (i+1) tl
    and right leftval acc = function
      | []       -> leftval -. (acc /. (float_of_int (n - k)))
      | (_,x)::t -> right leftval (acc +. (abs_float x)) t
    in
    left 0.0 0 lvec
  and apply_ks nleft k lvec : (int * float) list =
    if nleft < k then []
    else (k,resolve_k k lvec)::(apply_ks nleft (k+1) lvec)
  and take acc n lst = match lst with
    | _ when n = 0 -> List.rev acc,lst
    | []           -> assert false
    | x::lst       -> take (x::acc) (n-1) lst
  in
  (* return a list of lengths for subspaces *)
  let rec partition acc nsubs nused nleft lvec : int list =
    let sorted_ks = 
      List.sort (fun (_,kv1) (_,kv2) -> compare kv2 kv1) (apply_ks nleft 1 lvec)
    in
    let constraint_1 k = (* fall in appropriate range *)
      (strat.nsmin <= k) && (k <= strat.nsmax)
    and constraint_2 k = (* can be partitioned further *)
      let r =
          strat.nsmin * (int_of_float
              (ceil ((float_of_int (n-nused-k)) /. (float_of_int strat.nsmax)))) 
      in
      r <= (n-nused-k)
    in
    let rec get_next_k = function
      | (k,_)::_ when (constraint_1 k) && (constraint_2 k) ->
        if (nused+k) = n then 
          List.rev (k::acc)
        else
          partition (k::acc) (nsubs+1) (nused+k) (nleft-k) (snd (take [] k lvec))
      | _::tl -> get_next_k tl
      | []    -> assert false
    in
    get_next_k sorted_ks
  (* take a list of size of subspaces and  build association vectors for
      subspaces *)
  and build_association_arrays lvec = function
    | []    -> []
    | h::tl ->
      let this,oth = take [] h lvec in
      this::(build_association_arrays oth tl)
  in
  let lvec = 
    vec |> Array.mapi (fun i x -> (i,x))
        |> Array.to_list
        |> List.sort (fun (_,x) (_,y) -> compare (abs_float y) (abs_float x))
  in
  lvec |> partition [] 0 0 n
       |> build_association_arrays lvec
       |> List.map (List.map fst)
       |> List.map (Array.of_list)
 
(** Define how termination of the algorithm should be done. This is outlined in
    the paper, section 5.3.4, This test, because of a noisy function, uses the
    distance between the vertices of the simplex to see if the function has
    converged. *)
let subplex_termination strat tol dx x stp =
  let ret = ref false in
  Array.iteri
    (fun i _ ->
      let numr = max dx.(i) (abs_float (stp.(i) *. strat.psi))
      and denm = max (abs_float x.(i)) 1.0 in
      ret := !ret || ((numr /. denm) > tol))
    x;
  not (!ret)

(** The Subplex method is a generalization to a number of algorithms, paramount
    the Nelder-Mead simplex method, with alternating variables, and Nelder-Mead
    Simplex with restart. The advantages are outlined in the previously
    mentioned paper, in section 5.3.6. *)
let subplex_method ?(subplex_strategy=default_subplex) ?(tol=tolerance) ?(max_iter=50) 
                   ?(select_subspace=find_subspace) f (p,fp) =
  let i = ref 0 in
  let rec subplex_loop step subs ((x,_) as xfx) dx =
    incr i;
    let step = find_stepsize subplex_strategy (List.length subs) x dx step in
    let subs = select_subspace subplex_strategy dx in
    let (nx,_) as nxnfx =
      let simplex_strategy = subplex_strategy.simplex in
      List.fold_left
        (fun (x,fx) sub ->
          let sub_vec = make_subspace_vector sub x in
          let step    = Some (make_subspace_vector sub step) in
          let (nx,nfx) =
            Simplex.simplex_method ~simplex_strategy ~step (function_of_subspace f x sub) (sub_vec,fx)
          in
          replace_subspace_vector sub nx x;
          (x,nfx))
        xfx
        subs
      in
      let dx = sub_vec x nx in
      if (subplex_termination subplex_strategy tol dx nx step) || (!i > max_iter)
        then nxnfx
        else subplex_loop step subs nxnfx dx
    in
    let dx = Array.make (Array.length p) 0.0 in
    subplex_loop
      (find_stepsize subplex_strategy 1 p dx (Array.make (Array.length p) 1.0))
      [(Array.init (Array.length p) (fun x -> x))]
      (p,fp)
      (dx)
