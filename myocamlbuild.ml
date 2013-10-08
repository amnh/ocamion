open Ocamlbuild_plugin
open Command

(** Modifiable parameters *)
let static  = true
let mlflags = ["-w"; "@a"; "-warn-error"; "-a"]

let major,minor =
  let rec get_until i str acc =
    if (i >= (String.length str)) || ('.' = String.get str i)
      then String.concat "" (List.rev_map (String.make 1) acc),(i+1)
      else
          get_until (i+1) str ((String.get str i)::acc)
  in
  let major,n = get_until 0 Sys.ocaml_version [] in
  let minor,_ = get_until n Sys.ocaml_version [] in
  int_of_string major, int_of_string minor

(** Helper functions *)
let rec arg_weave p = function
  | x::xs -> (A p) :: (A x) :: arg_weave p xs
  | []    -> []

let arg x = A x
 
let () = dispatch begin function
  | Before_options ->
     let ocamlfind x = S[A"ocamlfind";arg x] in
     Options.ocamlmktop := ocamlfind "ocamlmktop";
    ()
  | After_rules ->
    (* pre-process / compile compatibility module *)
    let compatibility_options = 
      if major < 4 || ((major = 4) && minor <= 0)
        then [A"-pp";A"camlp4of -DCOMPATIBILITY"]
        else [A"-pp";A"camlp4of -UCOMPATIBILITY"]
    in
    flag ["ocaml";"use_compatibility";"ocamldoc"] (S compatibility_options);
    flag ["ocaml";"use_compatibility";"ocamldep"] (S compatibility_options);
    flag ["ocaml";"use_compatibility";"compile" ] (S compatibility_options);

    (* flags for ocaml compiling/linking *)
    flag ["ocaml"; "compile"]     (S (List.map arg mlflags));
    ()
  | _ -> ()
end
