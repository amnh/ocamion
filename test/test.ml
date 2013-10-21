open OUnit

let test_00 () = ()
let test_01 () = ()
let test_02 () = ()
let test_03 () = ()
let test_04 () = ()

let test_05 () = ()
let test_06 () = ()
let test_07 () = ()
let test_08 () = ()
let test_09 () = ()

let test_10 () = ()
let test_11 () = ()
let test_12 () = ()
let test_13 () = ()
let test_14 () = ()
let test_15 () = ()
let test_16 () = ()
let test_17 () = ()
let test_18 () = ()
let test_19 () = ()

let tests_0 =
  [
    "" >:: test_00;
    "" >:: test_01;
    "" >:: test_02;
    "" >:: test_03;
    "" >:: test_04;
  ]

let tests_1 =
  [
    "" >:: test_05;
    "" >:: test_06;
    "" >:: test_07;
    "" >:: test_08;
    "" >:: test_09;
  ]


let tests_2 =
  [
    "" >:: test_10;
    "" >:: test_11;
    "" >:: test_12;
    "" >:: test_13;
    "" >:: test_14;
    "" >:: test_15;
    "" >:: test_16;
    "" >:: test_17;
    "" >:: test_18;
    "" >:: test_19;
  ]

let tests =
  [
    "One-Dimensional Optimization"   >::: tests_0;
    "Multi-Dimensional Optimization" >::: tests_1;
    "Combinatorial Optimization"     >::: tests_2;
  ]

let () =
  ignore (OUnit.run_test_tt_main ("All" >::: tests))
