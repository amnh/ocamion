(** {6 Constants} *)

let tolerance = 1e-6

let epsilon   = 1e-10

let minimum   = tolerance *. 2.0

let pi = 4. *. atan 1.0

let golden = 0.3819660 (*-- constant for the golden ratio *)


(** {6 Floating Point Functions} *)

(** Check if a value is zero (takes into account negative; and subnormal *)
let is_zero x = match classify_float x with
        | FP_zero | FP_subnormal -> true
        | FP_infinite | FP_nan | FP_normal -> false

(** Check if a value is Not A Number *)
and is_nan x = match classify_float x with
        | FP_zero | FP_subnormal
        | FP_infinite | FP_normal -> false
        | FP_nan -> true

(** Check if a value is +/- infinity *)
and is_inf x = match classify_float x with
        | FP_infinite -> true
        | FP_nan | FP_zero | FP_subnormal | FP_normal -> false


(** {6 Types} *)

(** {6 Numerical Functions for Optimization Routines *)

(** find the derivative of a single variable function *)
let derivative ?(epsilon=epsilon) f x fx =
    let f_new = f (x +. epsilon) in
    (f_new -. fx) /. epsilon

(** find the magnitude of a vector x_array *)
let magnitude x_array = 
    sqrt (Array.fold_left (fun acc x -> acc +. (x *. x)) 0.00 x_array)

(** find the gradient of a multi-variant function at a point x_array *)
let gradient ?(epsilon=epsilon) f_ x_array f_array : float array =
    let i_replace i x v = let y = Array.copy x in Array.set y i v; y in
    Array.mapi
        (fun i i_val ->
            derivative
                    ~epsilon
                    (fun x ->
                        let newvec = i_replace i x_array x in
                        f_ newvec)
                    i_val
                    f_array)
        x_array

(** dot product of two arrays *)
let dot_product x_array y_array = 
    let n = Array.length x_array and r = ref 0.0 in
    assert (n = Array.length y_array);
    for i = 0 to n-1 do
        r := !r +. (x_array.(i) *. y_array.(i));
    done;
    !r

(** map a matrix with a function *)
let matrix_map f mat = 
    let n1 = Array.length mat and n2 = Array.length mat.(0) in
    let output_matrix = Array.create_matrix n1 n2 0.0 in
    for i = 0 to n1 - 1 do for j = 0 to n2 -1 do 
        output_matrix.(i).(j) <- f i j mat.(i).(j);
    done; done;
    output_matrix

(** Calculates the infinity-norm in L^p space. The Maximum Norm. *)
let inf_norm_vec x =
    Array.fold_left (max) (~-.max_float) x

(** Calculates the 2-norm in L^p space. The Euclidean Norm. *)
let two_norm_vec x =
    sqrt (Array.fold_left (fun acc x -> acc +. (x *. x)) 0.0 x)

(** Calculates the 1-norm in L^p space. The Taxicab Norm. *)
let one_norm_vec x =
    Array.fold_left (fun acc x -> acc +. (abs_float x)) 0.0 x

(** subtract one vector from another *)
let sub_vec x y = 
    Array.mapi (fun i _ -> x.(i) -. y.(i)) x

(** Add two vectors together with constant [c], c*x+y Imperative style *)
let add_veci x y = 
    for i = 0 to (Array.length x)-1 do
        x.(i) <- x.(i) +. y.(i);
    done;
    ()
