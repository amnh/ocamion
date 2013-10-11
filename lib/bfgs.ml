open Internal
open Numerical

(** BFGS Algorithm; Gradient Search Function *)
let optimize ?(max_iter=200) ?(epsilon=epsilon) ?(max_step=10.0) ?(tol=tolerance)
             ?(gradient=gradient ~epsilon) ?(line_search=LineSearch.optimize)
             f (p,fp) =
  let n = Array.length p and nf = float_of_int (Array.length p) and get_cost x = snd x  in
  let gradient f p fp =
    let f x = get_cost @@ f x in
    gradient f p @@ get_cost fp
  in
  (* Test convergence of a point --that it equals the direction, essentially *)
  let converged_l direction test_array =
    let test = ref 0.0 in
    Array.iteri
      (fun i x->
        let temp = max (abs_float x) 1.0 in
        test := max ((abs_float direction.(i)) /. temp) !test)
      test_array;
    (!test < (epsilon *. 4.0))
  (* Test the tolerance for zeroing of the gradient *)
  and converged_g fp gradient test_array =
    let test = ref 0.0
    and denom = max fp 1.0 in
    Array.iteri
      (fun i x ->
        let temp = (max (abs_float x) 1.0) /. denom in
        let temp = temp *. (abs_float gradient.(i)) in
        if temp > !test then test := temp)
      test_array;
    (!test < tol)
  (* Setup initial hessian (identity), initial gradiant vector, maximum step and direction *)
  and setup_function f_array x_array fx_array =
    let hessian =
      let h = Array.make_matrix n n 0.0 in
      for i = 0 to n-1 do h.(i).(i)  <- 1.0 done;
      h
    and x_grad = gradient f_array x_array fx_array in
    let dir = Array.map (fun x -> ~-. x) x_grad
    and mxstep = max_step *. (max (two_norm_vec x_array) nf) in
    hessian, x_grad, mxstep, dir in
  (* Do a line search step --return new p, new fp, new dir, if converged *)
  let line_searcher f p fp gradient maxstep direction =
    let np,nfp = line_search ~gradient ~maxstep ~direction f (p,fp) in
    let direction = Array.init n (fun i -> np.(i) -. p.(i) ) in
    np, nfp, direction
  (* Update gradient --ret new gradient, difference of gradients,
     difference of gradient times hessian matrix, if converged *)
  and gradient_update hessian ograd f p fp = 
    let ngrad = gradient f p fp in
    let dgrad = Array.init n (fun i -> ngrad.(i) -. ograd.(i)) in
    let hgrad = 
      Array.init n
        (fun i -> 
          let res = ref 0.0 in
          for j = 0 to n-1 do
            res := !res +. (hessian.(i).(j) *. dgrad.(j));
          done;
          !res)
    in
    ngrad, dgrad, hgrad
  (* Update the hessian matrix --skips the update if fac not sufficiently positive *)
  and bfgs_update_matrix dgrad hgrad direc hessian =
    let fac = Numerical.dot_product dgrad direc
    and fae = Numerical.dot_product dgrad hgrad
    and sumdgr = Array.fold_left (fun a x -> (x *. x) +. a) 0.0 dgrad
    and sumdir = Array.fold_left (fun a x -> (x *. x) +. a) 0.0 direc in
    if (fac *. fac) <= (epsilon *. sumdgr *. sumdir) then
      hessian
    else begin
      let fac = 1.0 /. fac and fad = 1.0 /. fae in
      let dgrad =
        Array.init n (fun i -> (fac *. direc.(i)) -. (fad *. hgrad.(i)))
      in
      matrix_map
        (fun i j x -> x +. (fac *. direc.(i) *. direc.(j))
                        -. (fad *. hgrad.(i) *. hgrad.(j))
                        +. (fae *. dgrad.(i) *. dgrad.(j)) )
        hessian
    end
  (* Calculate the new direction for the line search by the hessian matrix *)
  and calculate_direction hessian gradient =
    Array.init n
      (fun i ->
        let acc = ref 0.0 in
        for j = 0 to n-1 do
          acc := !acc -. (hessian.(i).(j) *. gradient.(j))
        done;
        !acc)
  in
  (* Main loop of algorithm *)
  let iter = ref 0 in
  let rec main_loop hessian f p fp step direction grad =
    incr iter;
    let np, nfp, direction = line_searcher f p fp grad step direction in
    if converged_l direction np then
      (np,nfp)
    else if (!iter > max_iter) then begin
      (np,nfp) (* TODO: add warning on max iterations *)
    end else begin
      let grad, dgrad, hgrad = gradient_update hessian grad f np nfp in
      if converged_g (get_cost nfp) grad np then begin
        (np,nfp)
      end else begin
        let hessian = bfgs_update_matrix dgrad hgrad direction hessian in
        let direction = calculate_direction hessian grad in
        main_loop hessian f np nfp step direction grad
      end
    end in
  (* initiate algorithm *)
  let hessian, pgrad, mxstep, dir = setup_function f p fp in
  main_loop hessian f p fp mxstep dir pgrad
