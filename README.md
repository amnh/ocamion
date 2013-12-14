OCamion
=======

A library of numerical and combinatorial optimization procedures written in
OCaml, with additional bindings for external optimization routines.


Methods
-------

OCaml Numerical Procedures -
  + [x] Simplex Method
  + [x] Subplex Method
  + [x] Brents Method 
  + [/] Multi-Dimensional Brents Method
  + [x] BFGS Method
  + [ ] Conjugate Gradient Method

OCaml Combinatorial Procedures -
  + [ ] Combinators for composing a search procedure
  + [ ] Simulated Annealing
  + [ ] Variable Neighborhood Search
  + [ ] Tabu Search
  + [ ] Genetic Algorithms

External Bindings -
  + [ ] GSL
  + [ ] ???


Combinatorial Optimization Mission Plan
---------------------------------------

The search framework will require thoughtfulness to be able to encompass a wide
range of known search heuristics. Since the motivation here is for phylogenetics,
we are dealing with two NP-Hard problems. We can look to current meta-heuristic
literature to design a general library. Most of these algorithms are dependent
on a local search. At minimum this requires,

+ Solution - An instance to a Problem
+ Neighborhood- A way to generate solutions using local modifications.
+ Choose - A method to choose a single member of a neighborhood for
  successive neighborhood searches.

Full search procedures, like branch and bound and depth first search will also
have to be employed as well to round out an exhaustive approach to search on
small data-sets. It is currently under consideration that the neighborhood be
generated from a lazy-list. In this way, we believe a wide range of options and
strategies can be employed from combining small fragments that embody a search
plan.

A local-search procedure can be used to build up a more global search
procedure that includes perturbations, a more robust tabu-search, and other
functionalities for global optimization and meta-heuristics. These procedures
can be defined separately instead of a single all encompassing search function,
and be parameterized about the specific requirements of the topology. In general
meta-heuristics can be separated into two categories:

Iterative Methods
+ Simulated Annealing (with restart)
+ Tabu-Search
+ Greedy Randomized Adaptive Search Procedure (GRASP)
+ Variable Neighborhood Search
+ Guided Local Search
+ Iterated Local Search

Population Based Methods
+ Scatter Search / Path Relinking
+ Evolutionary Computation (eg, GA)
+ Ant Colony Optimization
+ Firefly Optimization

The potential to compose these methods into hyper-heuristics is still a
question, but at the very least these methods encompass a wide range of ways
to vary the degrees of Intensification and Diversification. Some questions
remain regarding the search procedures,

+ Will this design be robust enough for parallel computation?
+ Does the first-class module cause speed/performance issues?
+ Can neighborhoods be partitioned effectively with the scheme we have?


Design Rational
---------------

+ neighborhoods as lazy-lists allow for filtering, look-ahead, tabu, and
  convergence options easily.
+ neighborhoods are composed of deltas of a candidate solution and not solutions
  themselves. This allows the problems solution itself to be a difficult problem
  and heuristics employed between testing a solution and accepting it as better.


Testing
-------

Testing is being done through OUnit. See the test/ directory for information.


Documentation/References
----------

Documentation can be built through `make docs` command. References are included
here from the source.


Authors/Contact
-------

  + Nicholas Lucaroni (nlucaroni at amnh dot org)
  + http://github.com/AMNH/ocamion
