open Numerical

type warnings = [ `StepConvergence | `LargeInitialSlope ] list

(** line search along a specified direction; Numerical Recipes in C : 9.7 *)
let optimize ?(epsilon=epsilon) ~gradient ~maxstep ~direction f (point,fpoint) =
  (* as in the previous function; we over-ride the local equality function for
      better control over the estimation process *)
  let get_cost x = snd x in
  let (=.) a b = (abs_float (a-.b)) < epsilon in
  (* set up some globals for the function to avoid tons of arguments *)
  let n = Array.length point and origfpoint = get_cost fpoint in
  (* scale direction so, |pstep| <= maxstep *)
  let setup_function point direction gradient = 
    let direction = (* ||dir|| <= maxstep *)
      let magstep = two_norm_vec direction in
      if magstep > maxstep
        then Array.map (fun x -> x *. maxstep /. magstep) direction 
        else direction
    in
    let slope = dot_product direction gradient
    and minstep = 
      let r = ref 0.0 in
      Array.iteri 
        (fun i x -> 
          let tmp = (abs_float direction.(i)) /. (max (abs_float x) 1.0) in
          if tmp > !r then r := tmp)
        point;
      epsilon /. (!r)
    and step = 1.0 in
    direction, slope, minstep, step
  (* find a new point and *)
  and next_step step prevstep slope newfpoint prevfpoint = 
    let newstep =
      if step =. 1.0 then
        ~-. slope /. (2.0 *. (newfpoint -. origfpoint -.  slope))
      else begin
        let tstep =
          let rhs1 = newfpoint -. origfpoint -. (step *. slope)
          and rhs2 = prevfpoint -. origfpoint -. (prevstep *. slope) in
          let rhs1divstepstep = rhs1 /. (step *. step)
          and rhs2divpsteppstep = rhs2 /. (prevstep *. prevstep) in
          let a =  rhs1divstepstep -. rhs2divpsteppstep
          and b = (step *. rhs2divpsteppstep) -. (prevstep *. rhs1divstepstep) in
          let a = a /. (step -. prevstep) and b = b /. (step -. prevstep) in
          if a =. 0.0 then
            ~-. slope /. (2.0 *. b)
          else begin
            let disc = (b *. b) -. (3.0 *. a *. slope) in
            if disc < 0.0 then 0.5 *. step
            else if b <= 0.0 then (~-. b +. (sqrt disc)) /. (3.0 *. a)
            else ~-. slope /. (b +. (sqrt disc))
          end
        in
        min tstep (0.5 *. step)
      end
    in
    max newstep (0.1 *. step)
  in
  (* main algorithm -- first instance sets up some variables *)
  let rec main_ prevfpoint slope direction step prevstep minstep = 
    if step < minstep then
      (point,fpoint) (* ,[`StepConvergence]) *)
    else begin
      let newpoint = Array.init n (fun i -> abs_float (point.(i) +. (step *. direction.(i)))) in
      let newfpoint = f newpoint in
      if (get_cost newfpoint) <= origfpoint then begin
        (newpoint,newfpoint)(*,[]*)
      end else begin
        let newstep = next_step step prevstep slope (get_cost newfpoint) prevfpoint in
        main_ (get_cost newfpoint) slope direction newstep step minstep
      end
    end
  in
  (* initialize and run... *)
  let direction, slope, minstep, step = setup_function point direction gradient in
  (* this could happen if the delta for gradient is huge (ie, errors in rediagnose) 
    * or some major instability in the tree/algorithm. The function will continue, 
    * but this warning message should report that the results are questionable. *)
  let res = main_ origfpoint slope direction step step minstep in
  if (abs_float slope) > 1_000_000.0
    then res (*,`LargeInitialSlope::warn *)
    else res (*,warn *)

