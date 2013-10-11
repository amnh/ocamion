OCamion
=======

A library of numerical and combinatorial optimization procedures in written in
OCaml, with additional bindings for external optimization routines. Brent and
BFGS methods have been used in POY for a number of years and are well tested,
the other methods are newer/less tested.


Methods
-------

OCaml Numerical Procedures -
  + [x] Simplex Method
  + [x] Subplex Method
  + [x] Brents Method 
  + [/] Multi-Dimensional Brents Method
  + [x] BFGS Method
  + [ ] Conjugate Gradient Methods

OCaml Combinatorial Procedures -
  + [ ] Simulated Annealing
  + [ ] Variable Neighborhood Search
  + [ ] Tabu Search
  + [ ] Genetic Algorithms

External Bindings -
  + [ ] GSL
  + [ ] ???


Testing
-------
Testing is being done through OUnit. See the test/ directory for information.


References
----------

@TECHREPORT{Rowan90functionalstability,
  author = {Thomas Harvey Rowan and Thomas Harvey Rowan and Thomas Harvey Rowan and Ph. D},
  title = {Functional Stability Analysis Of Numerical Algorithms},
  institution = {},
  year = {1990}
}

@BOOK{07numericalrecipes,
  author = {William H. Press and Saul A. Teukolsky and William T. Vetterling and Brian P. Flannery},
  title = {Numerical Recipes in C: The Art of Scientific Computing. Third Edition},
  year = {2007}
}


Authors/Contact
-------

  + Nicholas Lucaroni (nlucaroni at amnh dot org)
  + http://github.com/AMNH/ocamion
  
