open Internal
open MultiOptimize

module Summary = Pareto.Sample.Summary

type columns =
  [ `N | `Name | `Result_Mean | `Result_StdDev | `Time_Mean | `Time_StdDev
       | `Result_Skew | `Time_Skew | `Result_Kurt | `Time_Kurt | `Time_Var
       | `Result_Var | `Time_Min | `Time_Max | `Result_Min | `Result_Max ]

let bench ~d ~range ~n ~f : (string * (Summary.t * Summary.t)) list =
  (* Wrap [f] with additional information about # function evaluations. *)
  let f () =
    let count = ref 0 in
    (fun r -> incr count; f r), (fun () -> !count)
  in
  let init =
    let (lo,hi) = range in
    (fun () -> Array.init d (fun _ -> (Random.float (hi-.lo)) -. lo))
  in
  let empty = Summary.empty, Summary.empty in
  let rec for_num_iter ((time,res) as acc) optf n =
    if n = 0 then
      acc
    else
      begin
        let f,count = f () in
        let i = init () in
        let r = snd (snd (optf f (i,f i))) in
        let c = float_of_int (count ()) in
        for_num_iter (Summary.add time c,Summary.add res r) optf (n-1)
      end
  in
  List.map
    (fun (module Meth:MOPT) -> Meth.name, for_num_iter empty Meth.optimize n)
    MultiOptimize.all

let bench_table ?(columns=[`Name;`N;`Time_Mean;`Time_StdDev;`Result_Mean;`Result_StdDev]) summaries =
  let lookup_col (n,(t,r)) = function
    | `Name          -> n
    | `N             -> Summary.size     t |> string_of_int
    | `Time_StdDev   -> Summary.sd       t |> string_of_float
    | `Result_StdDev -> Summary.sd       r |> string_of_float
    | `Time_Mean     -> Summary.mean     t |> string_of_float
    | `Result_Mean   -> Summary.mean     r |> string_of_float
    | `Time_Var      -> Summary.variance t |> string_of_float
    | `Result_Var    -> Summary.variance r |> string_of_float
    | `Time_Kurt     -> Summary.kurtosis t |> string_of_float
    | `Result_Kurt   -> Summary.kurtosis r |> string_of_float
    | `Time_Skew     -> Summary.skewness t |> string_of_float
    | `Result_Skew   -> Summary.skewness r |> string_of_float
    | `Time_Min      -> Summary.min      t |> string_of_float
    | `Result_Min    -> Summary.min      r |> string_of_float
    | `Time_Max      -> Summary.max      t |> string_of_float
    | `Result_Max    -> Summary.max      r |> string_of_float
  and lookup_head = function
    | `Time_StdDev   -> "StdDev Time"
    | `Result_StdDev -> "StdDev Result"
    | `Time_Mean     -> "Mean Time"
    | `Result_Mean   -> "Mean Result"
    | `Time_Var      -> "Variance Time"
    | `Result_Var    -> "Variance Result"
    | `N             -> "Sample Size"
    | `Name          -> "Method Name"
    | `Time_Kurt     -> "Kurtosis Time"
    | `Result_Kurt   -> "Kurtosis Result"
    | `Time_Skew     -> "Skewness Time"
    | `Result_Skew   -> "Skewness Result"
    | `Time_Min      -> "Minimum Time"
    | `Result_Min    -> "Minimum Result"
    | `Time_Max      -> "Maximum Time"
    | `Result_Max    -> "Maximum Result"
  in
  let columns = Array.of_list columns in
  let c = Array.length columns in
  let table_body =
    List.map
      (fun data -> Array.init c (fun i -> lookup_col data columns.(i)))
      summaries
  in
  Array.of_list @@ (Array.map lookup_head columns) :: table_body

let output_bench ~channel (m : string array array) =
  let fold_lefti f i a =
    let acc = ref i in
    for i = 0 to (Array.length a)-1 do
      acc := f !acc i a.(i)
    done;
    !acc
  in
  let widths =
    Array.init
      (Array.length m.(0))
      (fun j ->
        fold_lefti (fun acc i _ -> max acc (String.length m.(i).(j))) 0 m)
  in
  Array.iteri
    (fun _ row_i ->
      Array.iteri
        (fun j elt_ij ->
          Printf.fprintf channel "% *s | " widths.(j) elt_ij)
        row_i;
      Printf.fprintf channel "\n")
    m

let report ~d ~range ~n ~f ~channel : unit =
  bench ~d ~range ~n ~f |> bench_table |> output_bench ~channel
