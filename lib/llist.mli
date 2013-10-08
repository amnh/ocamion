(** Lazy List API
    This module provides access to lazy-lists. The first element of the list is
    not lazy, thus some computation is made in creating the type. *)


(** {2 Type Definition} *)

(** An Empty (Nil) lazy list, and a cons cell containing some value and a lazy
    recursive list element. *)
type 'a llist = Nil
              | Cons of 'a * 'a llist Lazy.t


(** {2 Basic List Comprehension} *)

(** Returns the head of the list, this value is already forced so no computation
    is being done. *)
val hd : 'a llist -> 'a option

(** Returns the tail of the list. The new head of the list is forced. *)
val tl : 'a llist -> 'a llist option

(** Append an element to the front of the list. *)
val cons : 'a -> 'a llist -> 'a llist

(** Returns true if the list is empty. It is stressed this function should not
   typically be used as list comprehension should take care of termination *)
val is_nil : 'a llist -> bool

(** Returns the next [int] elements of the lazt list. *)
val take : int -> 'a llist -> 'a list

(** Filter a list by values that match the predicate. *)
val filter : ('a -> bool) -> 'a llist -> 'a llist

(** alias. filter *)
val (//) : 'a llist -> ('a -> bool) -> 'a llist

(** Continually accesses elements of the list and returns the first matching the
 * criteria defined in the predicate funciton. *)
val until : ('a -> bool) -> 'a llist -> 'a 

(** {2 Functions of 'a -> 'b} *)

(** Maps a function over the lazy list. *)
val map : ('a -> 'b) -> 'a llist -> 'b llist

(** A function that manages a state ['a] through the computation of the map of
    the function over the list. *)
val thread : ('a -> 'b -> 'a * 'c) -> 'a -> 'b llist -> 'c llist


(** {2 Functions in generating lazy-lists} *)

(** Create an integer indexed list *)
val of_fn_i : (int -> 'a) -> int -> 'a llist

(** Create a lazy list of an iterative function where the next element is a
   function of the previous. *)
val iterate : ('a -> 'a) -> 'a -> 'a llist

(** Create an infinite list of integers from [int]. *)
val from : int -> int llist

(** Return an infinite list of a constant value *)
val const : 'a -> 'a llist

(** Return a list of a single element. *)
val singleton : 'a -> 'a llist


(** {2 Functions for Combining lazy-lists} *)

(** Combines two lists alternating elements of each. *)
val weave : 'a llist -> 'a llist -> 'a llist

(** Function to combine to lists into a tuple *)
val combine : 'a llist -> 'b llist -> ('a * 'b) llist

(** Append one list onto the other; same as the infix [++]. *)
val append : 'a llist -> 'a llist -> 'a llist

(** alias. append *)
val ( ++ ) : 'a llist -> 'a llist -> 'a llist

(** Concatenate lazy-lists from a lazy-lists. *)
val concat : 'a llist llist -> 'a llist


(** {2 Folding } *)

(** fold over a lazy list with a function and accumulator. Will force list. *)
val fold : ('a -> 'b -> 'b) -> 'a llist -> 'b -> 'b


(** {2 Conversion Functions} *)

(** Produce a lazy-list from an OCaml stream *)
val of_stream : 'a Stream.t -> 'a llist

(** Produce a lazy-list from a list *)
val of_list : 'a list -> 'a llist


(** {2 Monadic Operators} *)

(** alias. singleton *)
val return : 'a -> 'a llist

(** Monadic bind operator for lazy-lists. *)
val bind : 'a llist -> ('a -> 'b llist) -> 'b llist
