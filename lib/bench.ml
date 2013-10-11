open Internal
open MultiOptimize

module Summary = Pareto.Sample.Summary

let bench ~d ~range ~n ~f : (string * (Summary.t * Summary.t)) list =
  (* Wrap [f] with additional information about how many times the function
     was evaluated, regarding output. *)
  let f () =
    let count = ref 0 in
    (fun r -> incr count; f r), (fun () -> !count)
  in
  (* Determine how to create initial vector *)
  let init =
    let (lo,hi) = range in
    (fun () -> Array.init d (fun _ -> (Random.float (lo+.hi)) -. lo))
  in
  (* Empty summary for iterations. *)
  let empty = Summary.empty, Summary.empty in
  (* loop for the number of iterations [n] *)
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
  (* loop over each type of optimization routine. *)
  List.map
    (fun (module Meth:MOPT) -> Meth.name, for_num_iter empty Meth.optimize n)
    MultiOptimize.all


(** Create a Benchmark table of data *)
let bench_table ?(columns=[`Name;`N;`Time_Mean;`Time_StdDev;`Result_Mean;`Result_StdDev]) channel summaries =
  let lookup_row (name,(time,result)) = function
    | `Time_StdDev   -> Summary.sd   time   |> string_of_float
    | `Result_StdDev -> Summary.sd   result |> string_of_float
    | `Time_Mean     -> Summary.mean time   |> string_of_float
    | `Result_Mean   -> Summary.mean result |> string_of_float
    | `N             -> Summary.size time   |> string_of_int
    | `Name          -> name
  and lookup_col = function
    | `Time_StdDev   -> "StdDev Time"
    | `Result_StdDev -> "StdDev Result"
    | `Time_Mean     -> "Mean Time"
    | `Result_Mean   -> "Mean Result"
    | `N             -> "Sample Size"
    | `Name          -> "Method Name"
  in
  let columns = Array.of_list columns in
  let c = Array.length columns in
  let table_body =
    List.map
      (fun data -> Array.init c (fun i -> lookup_row data columns.(i)))
      summaries
  in
  Array.of_list @@ (Array.map lookup_col columns) :: table_body
