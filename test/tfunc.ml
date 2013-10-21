(** {1 Tfunc}
    A suite of functions for testing numerical routines. *)

open Numerical

(** {2 Module definitions for Test Functions} *)

(** Module definition for functions of one dimension. *)
module type OneTestFunction =
  sig
    val f     : float -> float
    val name  : string
    val range : (float * float) option
    val is_min: ?tol:float -> float -> bool
  end

(** Module definition for functions of multiple dimension. The number of
    dimensions can be constrained with the [dim] value in the module. *)
module type MultiTestFunction =
  sig
    val f     : float array -> float
    val dim   : int option
    val range : (float * float) option
    val name  : string
    val is_min: ?tol:float -> float array -> bool
  end

(** Module definition for functions of multiple dimension with stochastic
    properties. This allows testing against functions which are not
    differentiable. The additional options includes an optional distribution
    function. Unless otherwise specified the distribution is uniform from zero
    to one. *)
module type StocMultiTestFunction =
  sig
    val f     : ?dist:(unit -> float) -> float array -> float
    val dim   : int option
    val range : (float * float) option
    val name  : string
    val is_min: ?tol:float -> float array -> bool
  end



(** {2 Helper functions} *)

(** test if a value is close to zero with given toleranace; many of these test
    functions have minimums at zero. *)
let is_zero tol fp = (abs_float fp) < tol

(** Uniform distribution for stochastic functions. *)
let uniform () = Random.float 1.0



(** {2 Implementations of Test Functions} *)


(** Quadratic function; simple test to ensure algorithms are working
    properly. The minimum is x= (0,0...0) *)
module Quadratic : MultiTestFunction =
  struct
    let f p = Array.fold_left (fun acc x -> acc +. (x *. x)) 0.0 p
    let name = "Quadratic Function"
    let dim = None
    let range = None
    let is_min ?(tol=tolerance) p = is_zero tol (f p)
  end


(** Quadratic function with stochasitc coefficients; same solution as above,
    the randomness ensures undiffernentiable, is x= (0,0...0). The default
    is a uniform distribution, others can be passed. *)
module StocQuadratic : StocMultiTestFunction =
  struct
    let f ?(dist=uniform) p =
      Array.fold_left (fun acc x -> acc +. (dist ()) *. (x *. x)) 0.0 p
    let name = "Stochastic Quadratic Function"
    let dim = None
    let range = None
    let is_min ?(tol=tolerance) p = is_zero tol (f p)
  end


(** Mutli-dimensional generalisation of the rosenbrock function; may have
    multiple minimums based on the number of dimensions (N=3 has one, N=4 has 2) *)
module Rosenbrock : MultiTestFunction =
  struct
    let f p =
      let total = ref 0.0 in
      for i = 0 to (Array.length p) - 2 do
        let one_d = 100.0 *. (p.(i+1) -. p.(i)**2.0)**2.0
        and two_d = (1.0 -. p.(i))**2.0 in
        total := !total +. one_d +. two_d;
      done;
      !total
    let name = "Rosenbrock Function"
    let dim = None
    let range = None
    let is_min ?(tol=tolerance) p = is_zero tol (f p) (** TODO **)
  end


(** Delta function with a minimum at [0_i] *)
module DiracDelta : MultiTestFunction =
  struct
    let f p =
      let res = ref true in
      for i = 0 to (Array.length p)-1 do
        if not ((abs_float p.(i)) < epsilon) then
          res := false
      done;
      if !res then infinity else 0.0
    let dim = None
    let range = None
    let name = "Dirac Delta Function"
    let is_min ?(tol=tolerance) p = is_zero tol (f p)
  end


(** Stochastic version of the rosenbrock function, passes into a distribution of
    a single parameter. The default is a uniform distribution. This makes it
    impossible to find an optimal point with a gradient method. The default
    is a uniform distribution, others can be passed. *)
module StocRosenbrock : StocMultiTestFunction =
  struct
    let f ?(dist=uniform) p =
      let total = ref 0.0 in
      for i = 0 to (Array.length p) - 2 do
        let two_d = (1.0 -. p.(i))**2.0
        and one_d = 100.0 *. (dist ()) *. (p.(i+1) -. p.(i)**2.0)**2.0 in
        total := !total +. two_d +. one_d;
      done;
      !total
    let dim = None
    let range = None
    let name = "Stochastic Rosenbrock Function"
    let is_min ?(tol=tolerance) p = is_zero tol (f p) (** TODO **)
  end


(** The rastigin function is a non-convex function for performance
    testings. global minimum at  {0,0...}, and range between +/- 5.12. *)
module Rastigin : MultiTestFunction =
  struct
    let f p =
      let total = ref 0.0 and a = 10.0 and pi = acos (-1.0) in
      for i = 0 to (Array.length p)-1 do
        let p_i = min (max ~-.5.12 p.(i)) 5.12 in
        total := !total +. (p_i *. p_i) -. a *. (cos (2.0 *. pi *. p_i))
      done;
      !total +. (a *. (float_of_int (Array.length p)))
    let dim = None
    let range = Some (-5.12,5.12)
    let name = "Rastigin Function"
    let is_min ?(tol=tolerance) p = is_zero tol (f p)
  end


(** Schwefel's function had a global minium that is geometrically distant
    from the other nearest local minimum. This tests convergance of the wrong
    direction of the optimization routine *)
module Schwefel : MultiTestFunction =
  struct
    let f p =
      Array.fold_left
        (fun acc x -> acc +. (~-. x *. (sin (sqrt (abs_float x))))) 0.0 p
    let dim = None
    let range = None
    let name = "Schewfel Function"
    let is_min ?(tol=tolerance) p = is_zero tol (f p) (** TODO **)
  end


(** Sum of different powers is a uni-modal function *)
module SumPowers : MultiTestFunction =
  struct
    let f p =
      let summ = ref 0.0 in
      for i = 0 to (Array.length p)-1 do
        summ := !summ +. (abs_float p.(i))**(float_of_int (i+1));
      done;
      !summ
    let dim = None
    let range = None
    let name = "Sum Powers"
    let is_min ?(tol=tolerance) p = is_zero tol (f p)
  end


(** Ackley function; global minima at f( x* ) = 0. *)
module Ackley : MultiTestFunction =
  struct
    let f p =
      let n = Array.length p and pi = acos (-1.0) in
      let left_sum = ref 0.0 and right_sum = ref 0.0 in
      for i = 0 to n-1 do
          left_sum := !left_sum +. (p.(i) ** 2.0);
          right_sum := !right_sum +. (cos (2.0 *. pi *. p.(i)));
      done;
      let left = ~-. 0.2 *. (sqrt (!left_sum /. (float_of_int n)))
      and right = !right_sum /. (float_of_int n) in
      ~-. 20.0 *. (exp left) -. (exp right) +. 20.0 +. (exp 1.0)
    let is_min ?(tol=tolerance) p = is_zero tol (f p)
    let dim = None
    let range = None
    let name = "Ackley Function"
  end


(** Michalewiczs function is a multi-modal test function with n! local
    optima, m, defines the steepness (set to 10.0), points outside an area
    give no information, while a few steep cliffs direct to minima. *)
module Michalewicz : MultiTestFunction =
  struct
    let f p =
      let sum = ref 0.0 and pi = acos (-1.0) in
      for i = 0 to (Array.length p) - 1 do
          let part = (sin ((float_of_int i)*.p.(i)*.p.(i) /. pi))**(20.0) in
          sum := !sum +. (sin p.(i)) *. part;
      done;
      !sum
    let name = "Michalewicz Function"
    let dim = None
    let range = None
    let is_min ?(tol=tolerance) p = is_zero tol (f p)
  end


(** The Hummelblau function is a multi-modal function with four optimal points.
    f( 3.000, 2.000) = 0.0     f(-2.805, 3.131) = 0.0
    f(-3.779,-3.283) = 0.0     f( 3.584,-1.848) = 0.0 *)
module Hummelblau : MultiTestFunction =
  struct
    let f p = 
      assert( (Array.length p) = 2 );
      ((p.(0)**2.0) +. p.(1) -. 11.0)**2.0 +.  ((p.(1)**2.0) +. p.(0) -. 7.0)**2.0
    let name = "Hummelblau Function"
    let dim = Some 2
    let range = None
    let is_min ?(tol=tolerance) p = assert false (** TODO **)
  end


(** The Booth function has several local minima, but a global minima at (1,3). *)
module Booth : MultiTestFunction =
  struct
    let f p = 
      assert( (Array.length p) = 2 );
      let left = ((p.(0) +. p.(1) +. p.(1) -. 7.0)**2.0)
      and rght = ((p.(0) +. p.(0) +. p.(1) -. 5.0)**2.0) in
      left +. rght
    let name = "Booth Function"
    let dim = Some 2
    let range = None
    let is_min ?(tol=tolerance) p = assert false (** TODO **)
  end


(** Functor to create a One-Dimensional Module From Multi-Dimensional *)
module OneOfMulti = functor (Multi : MultiTestFunction) ->
  struct
    let f p = Multi.f [|p|]
    let range = Multi.range
    let is_min ?tol p = Multi.is_min ?tol [|p|]
    let name = Multi.name
  end

(** Lists to categorize all modules *)

let multi_dim_modules : (module MultiTestFunction) list =
  [ (module Quadratic); (module Rosenbrock); (module Schwefel);
    (module Hummelblau); (module Booth); (module Michalewicz);
    (module Schwefel); (module Ackley); (module SumPowers);
    (module DiracDelta);
  ]

let stoc_multi_dim_modules : (module StocMultiTestFunction) list =
  [ (module StocRosenbrock); (module StocQuadratic); ]

let one_dim_modules : (module OneTestFunction) list =
  let of_multi =
    List.map
      (fun (module Multi : MultiTestFunction) -> match Multi.dim with
        | Some x when x > 1 -> []
        | _ -> [( module OneOfMulti (Multi) : OneTestFunction) ])
      multi_dim_modules
  in
  List.flatten of_multi
