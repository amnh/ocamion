(** {1 Bench}

    Benchmark a function against optimization methods. Currently this supports
    the multi-dimensional numerical optimization routines, thus this may change
    to unify with combinatorial functions. *)
 

(** {2 Types} *)

(** Define the columns to report data. The default columns are the name of the
    method, sample size [n], stddev and mean of both time and results.*) 
type columns =
  [ `N | `Name | `Result_Mean | `Result_StdDev | `Time_Mean | `Time_StdDev
       | `Result_Skew | `Time_Skew | `Result_Kurt | `Time_Kurt | `Time_Var
       | `Result_Var | `Time_Min | `Time_Max | `Result_Min | `Result_Max ]


(** {2 Benchmark Functions} *)

(** Benchmark the function [f] with all the numerical methods provided in
    [MultiOptimize.all]. The [bench] function returns a list of triples of the
    method name, a function timing summary, and a function result summary.
    Timing an abstraction of computational time by the number of function calls.
    This thus assumes that each call to [f] is approximately equal. The result
    summary will show the distribution of results of each optimization round.

    Many of the routines have extra data attached to the result of [f], here is
    is not necessary, but to continue with that framework it is in the signature
    here. Use [unit_wrapper] to fit a float result function. *)
val bench :
  d:int -> range:float * float -> n:int -> f:(float array -> 'a * float) ->
    (string * (Pareto.Sample.Summary.t * Pareto.Sample.Summary.t)) list

(** Generate a matrix of strings of the summaries against a list of columns to report. *)
val bench_table :
  ?columns:columns list ->
    (string * (Pareto.Sample.Summary.t * Pareto.Sample.Summary.t)) list -> string array array

(** Output the benchmark table. *)
val output_bench : channel:out_channel -> string array array -> unit

(** Do a full set of operations to output benchmark details. Use default columns. *)
val report : d:int -> range:float * float -> n:int -> f:(float array -> 'a * float) -> channel:out_channel -> unit
