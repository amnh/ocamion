type s = Problem.t

type t = int Problem.PairMap.t

type d = Problem.delta

type ('a,'b,'c) cost =
    { full_cost : 'a -> 'b -> 'c -> float * 'a;
      heuristic_cost : 'a -> 'b -> float * 'c; }
 
type ('a,'b,'c) tabu =
    { state : 'b;
      update_tabu : 'c -> 'b -> 'c;
      is_tabu : 'b -> 'c;  }

module Neighborhood =
  
  struct

    let neighborhood =

    let 

  end

module Tabu =
  struct

    let update_tabu d t : t =
      t |> ParMap.map (fun v -> v-1)
        |> PairMap.filter (fun _ v -> v < 0)
        |> (fun t -> match d with
            | `Swap (e1,e2) -> PairMap.add (PairMap.add t e2 max_time) e1 max_time
            | `Add e | `Remove e -> PairMap.add t e max_time)

    let is_tabu d t : bool = match d with
      | `Swap (e1,e2)      -> PairMap.mem t e1 && PairMap.mem t e2
      | `Add e | `Remove e -> PairMap.mem t e
  end


